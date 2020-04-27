<?php
        $WebHomePage = "http://{web_server}:{port}";

        //*****************************************************************
        //              Jenkins Server
        // $jenkins_srv = "http://192.168.0.198:8080";
        /*      user: cidana, password: cidana */
        $jenkins_srv = "http://cidana:115e256c408e0294f0caab845025055394@{jenkins_server}:8082";

        //*****************************************************************
        //              AWCY Server
        $awcy_srv = "http://{awcy_server}:3000/";

        //*****************************************************************
        //              data service Server
        // $api_server     = "http://app_server:8080";  // host access by other docker from inside
        $api_server_o = "http://{api_server}:8080";  // host access from outside
?>
