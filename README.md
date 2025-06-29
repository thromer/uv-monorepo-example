```
uv init --lib --no-readme lib-new
uv init --app --package --no-readme app-new
uv --directory app-new add --editable ../lib-new

...

uv --directory lib-new lock
uv --directory app-new lock
```

```
docker build -t monorepo -f Dockerfile .
docker build -t monorepo.merged -f Dockerfile.merged . && docker run monorepo.merged
```

```
docker build -t monorepo.1 -f Dockerfile.1 .
docker build -t monorepo.1.merged -f Dockerfile.1.merged . && docker run monorepo.1.merged
```
