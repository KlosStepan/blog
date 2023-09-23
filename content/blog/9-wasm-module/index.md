---
title: WebAssembly module in JavaScript
date: "2023-09-23T23:46:00.000Z"
---

We will describe how to implement simple modules and compile them to WebAssembly. Such module then can be used seamlessly in `Vanilla JavaScript web application` or `React.js web application` compiled as `JavaScript modules` [^1] and published at `npm` [^2] as `npm package`.

# Rust to WebAssembly
<p align="center">
  <img src="./rustwasmjs.png" alt="rust-wasm-js" style="width: 20%;" />
</p> 

First we prepare ourselves by installing Rust and Cargo to Unix system.
```
curl https://sh.rustup.rs -sSf | sh
```
Then we install `wasm-pack` for creating modularized Wasm binaries.
```
cargo install wasm-pack
``` 
Once we are ready we go to `/modules` folder and instantiate new one. We find it in `/modules/pwnrusthellowasm`.
```
cargo new --lib pwnrusthellowasm
```
We code our desired functionality in the Rust module.  

## Distribute Rust module as `npm package`
Rust to Wasm compilation can be carried out to accomodate `npm module` format as well. We have to set target to `--target bundler`. To prepare, or expose our prepared packed functionality run following commands in the appopriate module folder. Then `package.json` with appropriate entrypoint to `pwnrusthellowasm.js` is generated for us.  

## Rust to Wasm Overview
Rust[^3] is prepared to run in the web browser. There are several key takeways and tools making it possible.
- WebAssembly Core Specification (2019) [^4] bringing `Wasm` runtime to browser standard.
- `wasm-pack` tool for compiling code to WebAssembly.
- `wasm-bindgen` to communicate between Rust and JavaScript.

Then `Rust lib` -> `ES6 code` / `ES6 module`, `Cargo.toml` -> `package.json`, + `js wrapper`.  
Our final code, js wrapper and wasm is then found in `/pkg` directory.  

# Go to WebAssembly
TODO
# Wasm module in React.js (Next.js)
Demonstrational snippet usage on how to load `npm package` (acutal prepared and bundled Wasm binary) and use module's functions.  

```jsx
// Define a type for the Rust module
type IRustModule = {
  greet: (message: string) => null;
  greetStatic: () => string;
};

export default function Home() {
  const [count, setCount] = useState(0)
  const [rustModule, setRustModule] = useState<IRustModule | null>(null);
  useEffect(() => {
    // Dynamically import the Rust Wasm module
    import('pwnrusthellowasm').then((module: any) => {
      setRustModule(module);
    });
  }, []);
  const handleGreetClick = () => {
    if (rustModule) {
      const { greet } = rustModule;
      const result = greet('Calling Rust function greet(&str), popping back JS alert from Rust.');
      console.log(result);
    }
  };

  const handleGreetStaticClick = () => {
    if (rustModule) {
      const { greetStatic } = rustModule;
      const result = greetStatic();
      console.log(result);
    }
  };
  
  return (
    <>
        {/*...*/}
    </>
  )
}
```
[^1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
[^2]: https://www.npmjs.com/settings/pwnstepo/packages
[^3]: https://www.rust-lang.org
[^4]: https://www.w3.org/TR/wasm-core-1/