let instance = null;
let exports = null;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const sendString = (str) => {
  const encodedString = encoder.encode(str);

  const u8 = new Uint8Array(exports.mem);

  // Copy the UTF-8 encoded string into the WASM memory.
  u8.set(encodedString);
};

const objectBuffer = [];

const imports = {
  env: {
    stringObjExt: (location, size) => {
      const buffer = new Uint8Array(
        instance.exports.memory.buffer,
        location,
        size
      );

      const string = decoder.decode(buffer);

      const length = objectBuffer.length;
      objectBuffer.push(string);

      return length;
    },

    logObj: (value) => {
      console.log(objectBuffer[value]);
    },

    clearObjBuffer: () => {
      objectBuffer.length = 0;
    },
  },
};

fetch("binary.wasm")
  .then((resp) => WebAssembly.instantiateStreaming(resp, imports))
  .then((result) => {
    instance = result.instance;
    exports = instance.exports;

    // grab our exported function from wasm
    const add = exports.add;
    console.log(add(3, 4));
  });

const navbarInput = document.getElementById("navbarInput");
const navbarUploadButton = document.getElementById("navbarUploadButton");

const readFile = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);

    reader.readAsText(file);
  });

navbarUploadButton.addEventListener("click", (evt) => {
  evt.preventDefault();

  navbarInput.click();
});

navbarInput.addEventListener("change", (evt) => {
  evt.preventDefault();

  // evt.target.files is a FileList
  const files = Array.from(evt.target.files);

  files.forEach((file) => {
    console.log("changed", file);
  });
});
