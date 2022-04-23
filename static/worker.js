let wasmInstance = null;
let wasmExports = null;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const sendString = (str) => {
  const encodedString = encoder.encode(str);

  const u8 = new Uint8Array(exports.mem);

  // Copy the UTF-8 encoded string into the WASM memory.
  u8.set(encodedString);
};

const objectBuffer = [];

onmessage = (evt) => {
};

const imports = {
  env: {
    stringObjExt: (location, size) => {
      const buffer = new Uint8Array(
        wasmInstance.exports.memory.buffer,
        location,
        size
      );

      const string = decoder.decode(buffer);

      const length = objectBuffer.length;
      objectBuffer.push(string);

      return length;
    },

    clearObjBufferForObjAndAfter: (objIndex) => {
      objectBuffer.length = objIndex;
    },
    clearObjBuffer: () => {
      objectBuffer.length = 0;
    },

    logObj: (objIndex) => {
      const value = objectBuffer[objIndex];

      if (typeof value === "string") {
        postMessage(value);
      } else {
        postMessage(JSON.stringify(value) + "\n");
      }
    },
    // clearTerminal: () => {
    //   terminalText.innerText = "";
    // },

    exitExt: (objIndex) => {
      const value = objectBuffer[objIndex];

      throw new Error(`Crashed: ${value}`);
    },
  },
};

fetch("/binary.wasm")
  .then((resp) => WebAssembly.instantiateStreaming(resp, imports))
  .then((result) => {
    wasmInstance = result.instance;
    wasmExports = wasmInstance.exports;

    wasmExports.init();
  });
