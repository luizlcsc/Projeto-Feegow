const Video = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    return (
        <div className={"tm-video-parent-content"}>
            <div className={"tm-video-content"}>
                <video className={""} src="" id="pattern" autoPlay loop muted playsinline></video>
            </div>
            {/*<img style={{height: 170}} src="https://images.techhive.com/images/article/2016/10/win_20161005_17_53_45_pro-100686309-orig.jpg"alt=""/>*/}

            <div className={"tm-self-video-content"}>
                <canvas className={"tm-canvas-audio"} id="canvas" width="8" height="100"></canvas>
                <canvas className={"fa fa-info"} id="canvas" width="8" height="100"></canvas>

                <video className={"tm-video-content"} style={{width: 75}} src="" id="local" autoPlay loop muted playsinline></video>
                <small className={"message-error"} id="local-log"></small>
            </div>
        </div>
    );
};
