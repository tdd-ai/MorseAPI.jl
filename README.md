# Turkish Morphology API - MorseAPI.jl

This repo provides an API of [Morse.jl](https://github.com/ai-ku/Morse.jl#39f992e09b8a1ba1ebb030d90e62a13d8a2e3ec0) package.

The following project structure is recommended :

### Environment file [.env](.env)

This file will contain the path to packages file and other environment variables to be used in both the API package and Dockerfile.

Create your own version of the .env file and set the variables according to your application's required settings:

```shell
cp vars.env .env
```

Note that you must not share your own copy of .env file, since it might contain security related information (like authentication tokens). 

### Run directly

```bash
source .env
julia deploy/packagecompile.jl
julia --sysimage $LIB_PATH -e "MorseAPI.run()"
```

### Build docker image and run

```bash
source .env && docker build --build-arg api_port=$API_PORT --build-arg auth_token=$AUTH_TOKEN --build-arg lib_path=$LIB_PATH -t morse.jl_api:v0.1 .
docker run -p $API_PORT:$API_PORT -d morse.jl_api:v0.1
```

### Test API using cURL

if you are not in the same terminal window, run: `source .env` first.

```bash
curl -H "Auth-Token: "$AUTH_TOKEN -X POST -d '{"text":"Merhabalar, bugün nasılsınız ?"}' http://localhost:$API_PORT/analyze/
{'analysis': [
    ['merhabalar,', 'merhaba', '', 'Noun+A3pl+Pnon+Acc'],
    ['bugün', 'bugün', '', 'Noun+A3sg+Pnon+Nom'],
    ['nasılsınız', 'nasıl', '', 'Adj+^DB+Verb+Zero+Pres+A2pl'],
    ['?', '?', '', 'Punct']
  ]}
```

```bash
curl -H "Auth-Token: "$AUTH_TOKEN  -X POST -d '{"text":"this is some sentence. this is another sentence"}' http://localhost:$API_PORT/not-existing-api/
"not found"
```
