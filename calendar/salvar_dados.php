<?php
 require_once 'Google/autoload.php';
   session_start();	 	
/************************************************	
 The following 3 values an befound in the setting	
 for the application you created on Google 	 	
 Developers console.	 	 Developers console.
 The Key file should be placed in a location	 
 that is not accessable from the web. outside of 
 web root.	 
 	 	 
 In order to access your GA account you must	
 Add the Email address as a user at the 	
 ACCOUNT Level in the GA admin. 	 	
 ************************************************/
$client_id = '140536761331-cjuvapg8arfe7gscoju4dg3063p83lpr.apps.googleusercontent.com';
	$Email_address = '140536761331-compute@developer.gserviceaccount.com';	 
	$key_file_location = 'Calendario-c82c8af31694.p12';	 	
		$client = new Google_Client();	 	
	$client->setApplicationName("Client_Library_Examples");
	$key = file_get_contents($key_file_location);	 

// separate additional scopes with a comma	 
$scopes ="https://www.googleapis.com/auth/calendar"; 	
$cred = new Google_Auth_AssertionCredentials(	 
	$Email_address,	 	 
	array($scopes),	 	
	$key	 	 
	);	 	
$client->setAssertionCredentials($cred);
if($client->getAuth()->isAccessTokenExpired()) {	 	
	$client->getAuth()->refreshTokenWithAssertion($cred);	 	
}	 	
$service = new Google_Service_Calendar($client);    

$event = new Google_Service_Calendar_Event();
$event->setSummary($_GET['NomePaciente'].' - '.$_GET['NomeProcedimento']);
$event->setLocation('');
$start = new Google_Service_Calendar_EventDateTime();
//$start->setDateTime('2016-03-15T10:00:00.000-03:00');
$start->setDateTime($_GET['Inicio']);
$event->setStart($start);
$end = new Google_Service_Calendar_EventDateTime();
//$end->setDateTime('2016-03-15T10:25:00.000-03:00');
$end->setDateTime($_GET['Fim']);
$event->setEnd($end);
$attendee1 = new Google_Service_Calendar_EventAttendee();
$attendee1->setEmail($_GET['Email']);
// ...
$attendees = array($attendee1,
                   // ...
                  );
$event->attendees = $attendees;
$createdEvent = $service->events->insert('primary', $event);

echo $createdEvent->getId();


?>