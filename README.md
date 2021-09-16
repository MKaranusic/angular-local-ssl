1. Preinstall
    -- install certificate (run as administrator)
    >certutil -addstore Root .\server\sslcert\localhost.crt

    -- install express
    >npm i --save-dev express

2. Add server dir to root dir of your angular app

3. Change (server/node-server.js line 41) path to dist dir depending on your project config

4. Scripts
    -- build angular in prod mode
    >npm run build --prod

    -- run node server
    >node server/node-server.js