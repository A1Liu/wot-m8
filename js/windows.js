const WINDOWS = "windows-panel";
const HORIZONTAL = "windows-horizontal";
const VERTICAL = "windows-vertical";

const root = window.getElementById("windowRoot");

export const addHorizontalSibling = (domNode, child) => {
  if (domNode.classList.contains(HORIZONTAL)) {
    return;
  }

  if (domNode === root) {
  }


};


export const verticalSplit = () => {
};


