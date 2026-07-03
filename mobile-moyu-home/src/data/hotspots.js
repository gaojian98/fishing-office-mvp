export const DESIGN_SIZE = {
  width: 1024,
  height: 1536
};

// The uploaded draft is 1024 x 1536 while iPhone 13 preview is 390 x 844.
// "stretch" keeps every designed button visible. Replace home.png with a
// 390 x 844 high-res draft later to remove any visual distortion.
export const BACKGROUND_FIT = "stretch";

export const HOTSPOTS = [
  { id: "accountCenter", label: "账号中心", rect: { x: 26, y: 30, w: 305, h: 110 } },
  { id: "gameGuide", label: "游戏说明", rect: { x: 612, y: 28, w: 103, h: 118 } },
  { id: "gameHall", label: "游戏大厅", rect: { x: 735, y: 28, w: 112, h: 118 } },
  { id: "moyuStatus", label: "摸鱼", rect: { x: 868, y: 28, w: 105, h: 118 } },
  { id: "lakeMap", label: "湖畔垂钓", rect: { x: 612, y: 162, w: 112, h: 112 } },
  { id: "wallet", label: "钱包", rect: { x: 738, y: 162, w: 108, h: 112 } },
  { id: "logout", label: "退出", rect: { x: 868, y: 162, w: 105, h: 112 } },
  { id: "nameplate", label: "工位牌账号信息", rect: { x: 22, y: 922, w: 217, h: 112 } },
  { id: "taskBoard", label: "任务系统", rect: { x: 34, y: 1080, w: 238, h: 285 } },
  { id: "fishBook", label: "鱼类图鉴", rect: { x: 340, y: 1180, w: 158, h: 188 } },
  { id: "mouseCast", label: "鼠标上半区抛线", rect: { x: 640, y: 1212, w: 130, h: 70 } },
  { id: "mouseReel", label: "鼠标下半区收线", rect: { x: 640, y: 1280, w: 130, h: 74 } },
  { id: "shop", label: "商店", rect: { x: 45, y: 1378, w: 212, h: 145 } },
  { id: "glory", label: "荣耀", rect: { x: 284, y: 1378, w: 212, h: 145 } },
  { id: "bag", label: "背包", rect: { x: 522, y: 1378, w: 212, h: 145 } },
  { id: "startFishing", label: "开始钓鱼", rect: { x: 758, y: 1378, w: 230, h: 145 } }
];

export const ANIMATION_ANCHORS = {
  bobber: { x: 748, y: 590, w: 46, h: 86 },
  seaFishLeft: { x: 595, y: 570, w: 70, h: 78 },
  seaFishRight: { x: 835, y: 590, w: 82, h: 92 },
  line: { x: 780, y: 820, w: 150, h: 310 }
};
