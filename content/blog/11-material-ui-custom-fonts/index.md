---
title: Material UI custom fonts
date: "2024-05-20T18:50:00.000Z"
---

In this post I will show how to use custom fonts in Material UI in React application. The reason is that I found it troubling and seemingly intuitive setup didn't work. 

We will use `external fonts` from these 2 sources:
- TrueType font (`.ttf file`),
- `fountsource` font as NPM packages.  

We use `createTheme` [^1] for styling of our web application. Watch for fonts `PixGamer` and `IBM Plex Sans Condensed` in screenshot - how they are used.  
<p align="center">
  <img src="./font-imports-1.png" alt="font-imports-1"/>
</p> 

# TrueType font  
Some fonts, unfortunately, are only distrubuted as `.tff` or `.woff`.  
We must load font in `MuiCssBaseline`[^2] in `theme.js` (external file including createTheme) and specify source `src` there. We then must use `<CssBaseline />` which "serves as CSS reset" for MUI. Also, `.tff` is specified as `truetype` in import format.  
Once we have these things in place, we use font in `typography`.

# fontsource font
This is way easier with no ambiguity. First install the font via npm.
```
npm i @fontsource/ibm-plex-sans-condensed
```  
We than see that font has appeared in `package.json`
```
{
  "name": "...",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@fontsource/ibm-plex-sans-condensed": "^5.0.13",
    ...
```  
In `theme.js` import the font before theme definition as follows
```
const ibmPlexSansCondensed = require('@fontsource/ibm-plex-sans-condensed');
```   
and then reference it around as `IBM Plex Sans Condensed`.  

[^1]: https://mui.com/material-ui/customization/theming/#custom-variables
[^2]: https://mui.com/material-ui/react-css-baseline
