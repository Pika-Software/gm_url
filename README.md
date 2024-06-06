## API
```lua
class URL
    new(url: string, base?: string)
    
    -- If field does not exists, it will be nil
    href: string -- full url
    origin: string -- *readonly* origin of the url ¯\_(ツ)_/¯
    scheme: string -- just a plain scheme
    protocol: string -- a scheme with ':' appended at the end
    username: string
    password: string
    hostname: string
    host: string -- hostname + port
    port: number
    pathname: string
    query: string
    search: string -- a query with '?' prepended
    searchParams: nil -- is not implemented
    fragment: string
    hash: string -- a fragment with '#' prepended


URL URL.parse(url: string, base?: string)
bool URL.canParse(url: string, base?: string)
```
