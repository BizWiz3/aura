# 🌙 Aura

The HTTP client for Lune. Aura is a lightweight wrapper around Lune's native net library for handling request. Inspired by Axios, it simplifies data fetching by handling JSON encoding/decoding, URL normalization, and standardized response objects automatically.

## ✨ Features

**Auto-JSON:** Automatically encodes request bodies and decodes response bodies.

**Zero-Lag Localhost:** Automatically patches the Windows localhost IPv6 delay (2s → 4ms).

**Safe Decoding:** Uses pcall to ensure malformed JSON doesn't crash your runtime.

**Standardized:** Consistent response objects across all HTTP methods.

## Installation

```bash
pesde add bizwis3/aura
pesde install
```

## Quick Start

### Basic GET Request

```lua
local aura = require("path/to/aura")
local res = aura.get({ url = "https://jsonplaceholder.typicode.com/posts/1" })

if res.ok then
    print(res.body.title) -- Already decoded into a table!
end
```

### Basic POST Request

```lua
local res = aura.post({
    url = "http://localhost:8080/users",
    body = {
        name = "John Doe",
        job = "Lune Developer"
    }
})
```

## API Reference

**REQUEST CONFIGURATION (`AuraRequest`)**

| Property | Type | Description |
| :--- | :--- | :--- |
| **url** | `string` | The target URL. |
| **method** | `string` | HTTP Method (GET, POST, etc). |
| **body** | `table` or `string` | Data to be sent. Tables are auto-JSON encoded. |
| **headers** | `table` | Custom HTTP headers. |
| **query** | `table` | URL Query parameters. |
| **options** | `table` | Options |
|

**RESPONSE OBJECT (`AuraResponse`)**

| Property | Type | Description |
| :--- | :--- | :--- |
| **ok** | `boolean` | `true` if the status code is 200-299. |
| **status** | `number` | The HTTP status code (e.g., 200, 404). |
| **statusMessage** | `string` | The status text from the server (e.g., "OK"). |
| **headers** | `table` | A dictionary of response headers. |
| **body** | `any` | The decoded JSON table or raw response string. |
|

## Example Errors

```sh
Aura Request got an issue:

 Status : 300 (Multiple Choices)
 Method : GET
 URL    : http://localhost:8080/
 Time   : 0.0019 seconds
```

```sh
Aura Request got an issue:

 Status : 404 (Not Found)
 Method : GET
 URL    : http://localhost:8080/notfound
 Time   : 0.0015 seconds
```
