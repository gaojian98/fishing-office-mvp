import { BACKGROUND_FIT, DESIGN_SIZE } from "../data/hotspots";

export function getImageFrame(containerWidth, containerHeight) {
  const scaleX = containerWidth / DESIGN_SIZE.width;
  const scaleY = containerHeight / DESIGN_SIZE.height;

  if (BACKGROUND_FIT === "stretch") {
    return {
      x: 0,
      y: 0,
      width: containerWidth,
      height: containerHeight,
      scaleX,
      scaleY
    };
  }

  const scale = BACKGROUND_FIT === "cover"
    ? Math.max(scaleX, scaleY)
    : Math.min(scaleX, scaleY);

  const width = DESIGN_SIZE.width * scale;
  const height = DESIGN_SIZE.height * scale;

  return {
    x: (containerWidth - width) / 2,
    y: (containerHeight - height) / 2,
    width,
    height,
    scaleX: scale,
    scaleY: scale
  };
}

export function mapRect(rect, frame) {
  return {
    left: frame.x + rect.x * frame.scaleX,
    top: frame.y + rect.y * frame.scaleY,
    width: rect.w * frame.scaleX,
    height: rect.h * frame.scaleY
  };
}
