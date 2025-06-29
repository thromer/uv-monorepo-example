```
uv init --lib --no-readme lib-new
uv init --app --package --no-readme app-new
uv --directory app-new add --editable ../lib-new

...

uv --directory lib-new lock
uv --directory app-new lock
```

```
docker build -t monorepo-merged -f Docker
docker build -t monorepo-merged -f Dockerfile.merged
docker run monorepo-merged
```
