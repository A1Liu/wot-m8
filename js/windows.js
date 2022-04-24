const PANEL = "windows-panel";
const RESIZER = "windows-resizer";
const TABBED = "windows-tabbed";
const TAB_BAR = "windows-tabbar";
const TAB = "windows-tab";

const VERTICAL = "vertical"; // top-to-bottom
const HORIZONTAL = "horizontal"; // left-to-right

export const AFTER = "windows-AFTER";
export const BEFORE = "windows-BEFORE";

export const TabbedWindow = (title, content) => {
  const tabbedWindow = document.createElement("div");
  const tabBar = document.createElement("div");
  const tab = document.createElement("div");

  tabbedWindow.classList.add(TABBED);
  tabBar.classList.add(TAB_BAR);
  tab.classList.add(TAB);

  tab.textContent = title;

  tabBar.appendChild(tab);
  tabbedWindow.appendChild(tabBar);
  tabbedWindow.appendChild(content);

  return tabbedWindow;
};

export const addHorizontalSibling = (domNode, child, position = AFTER) => {
  const parent = domNode.parent;
  if (parent.classList.contains(HORIZONTAL)) {
    domNode.insertAdjacentElement("beforebegin", child);

    return;
  }
};

let resizeState = null;

window.addEventListener("mouseup", (evt) => {
  if (resizeState) {
    evt.preventDefault();

    resizeState = null;
  }
});

window.addEventListener("mousemove", (evt) => {
  if (resizeState) {
    evt.preventDefault();

    const newPos = resizeState.isVert ? evt.clientY : evt.clientX;
    resizeState.beforeSize += newPos - resizeState.pos;
    resizeState.pos = newPos;

    const beforeSize = resizeState.beforeSize;
    const childSize = resizeState.parentSize - resizeState.beforeSize;

    if (resizeState.isVert) {
      resizeState.resizerBefore.style.height = `${beforeSize}px`;
      resizeState.child.style.height = `${childSize - 1}px`;
    } else {
      resizeState.resizerBefore.style.width = `${beforeSize}px`;
      resizeState.child.style.width = `${childSize - 1}px`;
    }
  }
});

export const appendChild = (parent, child) => {
  const classList = parent.classList;
  const isVert = classList.contains(VERTICAL);
  const isHorizontal = classList.contains(HORIZONTAL);

  const isValid = classList.contains(PANEL) && (isVert || isHorizontal);
  if (!isValid) {
    console.warn("tried to append to invalid value");
    return;
  }

  const parentBox = parent.getBoundingClientRect();
  child.style.width = `100%`;
  child.style.height = `100%`;

  if (parent.children.length <= 0) {
    parent.appendChild(child);
    return;
  }

  const parentSize = isVert ? parentBox.height : parentBox.width;
  const resizerBefore = parent.lastChild;

  const resizer = document.createElement("span");
  resizer.classList.add(RESIZER);
  resizer.role = "presentation";

  let beforeSize = parentSize / 2;
  let resizing = false;
  let pos = null;

  // TODO cleanup event listeners added to window
  resizer.addEventListener("mousedown", (evt) => {
    evt.preventDefault();
    evt.stopPropagation();

    resizeState = {
      isVert,
      resizerBefore,
      child,
      beforeSize,
      parentSize,
      pos: isVert ? evt.clientY : evt.clientX,
    };
  });

  if (isVert) {
    resizerBefore.style.height = `${beforeSize}px`;
    child.style.height = `${beforeSize - 1}px`;
  } else {
    resizerBefore.style.width = `${beforeSize}px`;
    child.style.width = `${beforeSize - 1}px`;
  }

  parent.appendChild(resizer);
  parent.appendChild(child);

  return;
};
