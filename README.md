###### Cidana Test Platform

# TFS Configuration

### Files

There are total 2 files should be changed.

1. `data_service_api/conf/app.conf`
2. `web_ui/www/ apiCfg.php`

#
---
## - data_service_api/conf/app.conf -
app.conf is used to set `Jenkins's ip`, `awcy_addr_map`, `Trust Domain`, `CORS allowOrigins`, and `front web site` .

##### HOW TO Modify
1. Jenkins Setting
    jenkins_host = http://%sctpqa.cidanash.com:8082 → 
   `jenkins_host = http://%s{your jenkins ip}=:{your jenkins port}`
2. awcy settings
   awcy_addr_map = {"172.17.0.1" : "ctpqa.cidanash.com"}   → 
   `awcy_addr_map = {"172.17.0.1" : "your awcy server ip"}`
3. Trust Domain setting
   trusted_zone = [{"Name": "Jenkins Server", "IP": "ctpqa.cidana.com"}, {"Name": "docker", "IP": "172.17.0.1"}]  → 
  `trusted_zone = [{"Name": "Jenkins Server", "IP": "your jenkins ip"}, {"Name": "docker", "IP": "172.17.0.1"}]`
4. CORS allowOrigins setting
   origins = [{"host": "http://ctpqa.cidanash.com:8083"}]  →
   `origins = [{"host": "http://your web ui ip:your web ui port"}]`


#
---
## - web_ui/www/ apiCfg.php -
apiCfg.php is used to set `$WebHomePage`, `$jenkins_srv `, `$awcy_srv ` and  `$api_server_o `

##### HOW TO Modify
1. WebHomePage
   `$WebHomePage="http://ctpqa.cidanash.com:8083";` →
   `$WebHomePage="http://:your web ui ip:your web ui port";`
2. jenkins_srv
   `$jenkins_srv = "http://ctpqa.cidanash.com:8082";` → 
   `$jenkins_srv = "http://your jenkins ip:your jenkins port";`
3. awcy_srv
   `$awcy_srv = "http://ctpqa.cidanash.com:3000/";` →
   `$awcy_srv = "http://your awcy ip:your awcy port/";`
4. api_server_o 
   `$api_server_o   = "http://ctpqa.cidanash.com:8080";` →
   `$api_server_o   = "http://your api server ip:your api server port"`

#
---
## - How to kown your ip and server's port -
##### e.g
> docker run --rm --name jenkins -p 8082:8080 -p 50000:50000 -d cidana/jenkins:deploy

`8082:8080` the 8082 is host access from outside, 8080 is host access from inside
So you should input 8082 in {your server port}