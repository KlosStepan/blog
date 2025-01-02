---
title: Vanilla JavaScript with TypeScript Frontend
date: "2024-06-13T12:55:00.000Z"
---

We will create minimalistic Vanilla JS with TypeScript setup for frontend. There are several options, such as `parcel` or more complicated setups with `sass` and `scss` - we are not going to talk about these.  

The point of this article is to kick off minimalistic setup only with TypeScript, to allow convenient hot-reloading and straightforward serve with `npm start`.  

![JavaScript TypeScript abstraction](./ComfyUI_00001_.png)
## 1. Initialize project  
```
mkdir vanillajs-ts-frontend
cd vanillajs-ts-frontend
npm init -y
```
## 2. Install packages  
```
npm install typescript tsc-watch --save-dev
```
## 3. Create TypeScript configuration  
```
{
  "compilerOptions": {
    "target": "es6",
    "module": "es6",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"]
}
```
## 4. Set up Directory Structure  
```
mkdir src
```
## 5. Create an Entry Point  
```
const app = document.getElementById('app');

if (app) {
  app.innerHTML = '<h1>Hello, TypeScript!</h1>';
}
```  
Create an `index.html` file in the root directory to serve the application:
```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My TypeScript Project</title>
</head>
<body>
  <div id="app"></div>
  <script src="./dist/index.js"></script>
</body>
</html>
```  
## 6. Set up `npm scripts`  
Modify `scripts` section in your `package.json` to include scripts for starting and building your project:  
```
"scripts": {
  "start": "tsc-watch --onSuccess \"lite-server\"",
  "build": "tsc"
}
```  
## 7. Install lite-server for the Development  
Install lite-server to serve your application during development:
```
npm install lite-server --save-dev
```
Create a bs-config.json file in the root directory to configure lite-server:
```
{
  "server": {
    "baseDir": "./",
    "routes": {
      "/dist": "dist"
    }
  }
}
```
## 8. Run Your Project  
To start your project with hot reloading, run:
```
npm start
```
To build your project for production, do:
```
npm run build
```
## Summary  
With these steps, you have a simple setup for a Vanilla JavaScript TypeScript frontend project that supports hot reloading via `tsc-watch` and includes npm `scripts` for starting and building your project. This setup can be further expanded based on your project's specific needs.