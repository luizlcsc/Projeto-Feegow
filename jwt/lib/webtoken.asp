<%
/*
***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1/GPL 2.0/LGPL 2.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* Contributor(s):
*   Michael Hanson <mhanson@mozilla.com>
*
* Alternatively, the contents of this file may be used under the terms of
* either the GNU General Public License Version 2 or later (the "GPL"), or
* the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
* in which case the provisions of the GPL or the LGPL are applicable instead
* of those above. If you wish to allow use of your version of this file only
* under the terms of either the GPL or the LGPL, and not to allow others to
* use your version of this file under the terms of the MPL, indicate your
* decision by deleting the provisions above and replace them with the notice
* and other provisions required by the GPL or the LGPL. If you do not delete
* the provisions above, a recipient may use your version of this file under
* the terms of any one of the MPL, the GPL or the LGPL.
*
* ***** END LICENSE BLOCK ***** */

var jwt = {};

var JWTInternals = (function() {

  // convert a base64url string to hex
  var b64urlmap="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  function b64urltohex(s) {
    var ret = ""
    var i;
    var k = 0; // b64 state, 0-3
    var slop;
    for(i = 0; i < s.length; ++i) {
      var v = b64urlmap.indexOf(s.charAt(i));
      if(v < 0) continue;
      if(k == 0) {
        ret += int2char(v >> 2);
        slop = v & 3;
        k = 1;
      }
      else if(k == 1) {
        ret += int2char((slop << 2) | (v >> 4));
        slop = v & 0xf;
        k = 2;
      }
      else if(k == 2) {
        ret += int2char(slop);
        ret += int2char(v >> 2);
        slop = v & 3;
        k = 3;
      }
      else {
        ret += int2char((slop << 2) | (v >> 4));
        ret += int2char(v & 0xf);
        k = 0;
      }
    }
    if(k == 1)
      ret += int2char(slop << 2);
    return ret;
  }



  function base64urlencode(arg)
  {
    var s = base64encode(arg); // Standard base64 encoder
    s = s.split('=')[0]; // Remove any trailing '='s
    s = s.replace(/\+/g, '-'); // 62nd char of encoding
    s = s.replace(/\//g, '_'); // 63rd char of encoding
    // TODO optimize this; we can do much better
    return s;
  }

  function base64urldecode(arg)
  {
    var s = arg;
    s = s.replace(/-/g, '+'); // 62nd char of encoding
    s = s.replace(/_/g, '/'); // 63rd char of encoding
    switch (s.length % 4) // Pad with trailing '='s
    {
      case 0: break; // No pad chars in this case
      case 2: s += "=="; break; // Two pad chars
      case 3: s += "="; break; // One pad char
      default: throw new InputException("Illegal base64url string!");
    }
    return Base64Encoder.decode(s); // Standard base64 decoder
  }

  function NoSuchAlgorithmException(message) {
    this.message = message;
    this.toString = function() { return "No such algorithm: "+this.message; };
  }
  function NotImplementedException(message) {
    this.message = message;
    this.toString = function() { return "Not implemented: "+this.message; };
  }
  function InputException(message) {
    this.message = message;
    this.toString = function() { return "Malformed input: "+this.message; };
  }

  function HMACAlgorithm(hash, key)
  {
    if (hash == "sha256") {
      this.hash = sjcl.hash.sha256;
    } else {
      throw new NoSuchAlgorithmException("HMAC does not support hash " + hash);
    }
    this.key = sjcl.codec.utf8String.toBits(key);
  }

  HMACAlgorithm.prototype = 
  {
    update: function _update(data)
    {
      this.data = data;
    },
    
    finalize: function _finalize()
    {
    },
    
    sign: function _sign()
    {
      var hmac = new sjcl.misc.hmac(this.key, this.hash);
      var result = hmac.encrypt(this.data);
      return base64urlencode(base64decode(sjcl.codec.base64.fromBits(result)));
    },
    
    verify: function _verify(sig)
    {
      var hmac = new sjcl.misc.hmac(this.key, this.hash);
      var result = hmac.encrypt(this.data);
      
      return base64urlencode(base64decode(sjcl.codec.base64.fromBits(result))) == sig; 
    }
  }

  function RSASHAAlgorithm(hash, keyPEM)
  {
    if (hash == "sha1") {
      this.hash = "sha1";
    } else if (hash == "sha256") {
      this.hash = "sha256";
    } else {
      throw new NoSuchAlgorithmException("JWT algorithm: " + hash);  
    }
    this.keyPEM = keyPEM;
  }
  RSASHAAlgorithm.prototype =
  {
    update: function _update(data)
    {
      this.data = data;
    },
    finalize: function _finalize()
    {
    
    },
    sign: function _sign()
    {
      var rsa = new RSAKey();
      rsa.readPrivateKeyFromPEMString(this.keyPEM);
      var hSig = rsa.signString(this.data, this.hash);
      return base64urlencode(base64urldecode(hex2b64(hSig))); // TODO replace this with hex2b64urlencode!
    },
    verify: function _verify(sig)
    {
      var result = this.keyPEM.verifyString(this.data, b64urltohex(sig));
      return result;
    }
  }

  function WebToken(objectStr, algorithm)
  {
    this.objectStr = objectStr;
    this.pkAlgorithm = algorithm;
  }

  var WebTokenParser = {

    parse: function _parse(input)
    {
      var parts = input.split(".");
      if (parts.length != 3) {
        throw new MalformedWebToken("Must have three parts");
      }
      var token = new WebToken();
      token.headerSegment = parts[0];
      token.payloadSegment = parts[1];
      token.cryptoSegment = parts[2];

      token.pkAlgorithm = base64urldecode(parts[0]);
      return token;
    }
  }

  function jsonObj(strOrObject)
  {
    if (typeof strOrObject == "string") {
      return eval("("+strOrObject+")");
    }
    return strOrObject;
  }

  function constructAlgorithm(jwtAlgStr, key)
  {
    if ("ES256" === jwtAlgStr) {
      throw new NotImplementedException("ECDSA-SHA256 not yet implemented");
    } else if ("ES384" === jwtAlgStr) {
      throw new NotImplementedException("ECDSA-SHA384 not yet implemented");
    } else if ("ES512" === jwtAlgStr) {
      throw new NotImplementedException("ECDSA-SHA512 not yet implemented");
    } else if ("HS256" === jwtAlgStr) {
      return new HMACAlgorithm("sha256", key);
    } else if ("HS384" === jwtAlgStr) {
      throw new NotImplementedException("HMAC-SHA384 not yet implemented");
    } else if ("HS512" === jwtAlgStr) {
      throw new NotImplementedException("HMAC-SHA512 not yet implemented");
    } else if ("RS256" === jwtAlgStr) {
      return new RSASHAAlgorithm("sha256", key);
    } else if ("RS384" === jwtAlgStr) {
      throw new NotImplementedException("RSA-SHA384 not yet implemented");
    } else if ("RS512" === jwtAlgStr) {
      throw new NotImplementedException("RSA-SHA512 not yet implemented");
    } else {
      throw new NoSuchAlgorithmException("Unknown algorithm: " + jwtAlgStr);
    }
  }

  WebToken.prototype =
  {
    serialize: function _serialize(key)
    {
      var header = jsonObj(this.pkAlgorithm);
      var jwtAlgStr = header.alg;
      var algorithm = constructAlgorithm(jwtAlgStr, key);
      var algBytes = base64urlencode(this.pkAlgorithm);
      var jsonBytes = base64urlencode(this.objectStr);

      var stringToSign = algBytes + "." + jsonBytes;
      algorithm.update(stringToSign);
      var digestValue = algorithm.finalize();

      var signatureValue = algorithm.sign();
      return algBytes + "." + jsonBytes + "." + signatureValue;
    },
    
    verify: function _verify(key)
    {
      var header = jsonObj(this.pkAlgorithm);
      var jwtAlgStr = header.alg;
      var algorithm = constructAlgorithm(jwtAlgStr, key);
      algorithm.update(this.headerSegment + "." + this.payloadSegment);
      algorithm.finalize();
      return algorithm.verify(this.cryptoSegment);
    }
  }
  
  jwt.WebToken = WebToken;
  jwt.WebTokenParser = WebTokenParser;
  jwt.base64urlencode = base64urlencode;
  jwt.base64urldecode = base64urldecode;
})();
%>