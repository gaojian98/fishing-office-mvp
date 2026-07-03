import React, { useEffect, useMemo, useRef, useState } from "react";
import {
  Animated,
  ImageBackground,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  useWindowDimensions,
  View
} from "react-native";
import HotspotButton from "./components/HotspotButton";
import ShopModal from "./components/ShopModal";
import GloryModal from "./components/GloryModal";
import BagModal from "./components/BagModal";
import GameModal from "./components/GameModal";
import { ANIMATION_ANCHORS, BACKGROUND_FIT, HOTSPOTS } from "./data/hotspots";
import { fishList } from "./data/gameData";
import { getImageFrame, mapRect } from "./utils/layout";

const backgroundImage = require("../assets/ui/home.png");
const MODAL_TITLES = {
  accountCenter: "账号中心",
  gameGuide: "游戏说明",
  gameHall: "游戏大厅",
  moyuStatus: "钓鱼状态",
  lakeMap: "湖畔垂钓",
  wallet: "钱包",
  logout: "退出登录",
  nameplate: "账号信息",
  taskBoard: "今日任务",
  fishBook: "鱼类图鉴",
  caught: "获得鱼获"
};

export default function App() {
  const { width, height } = useWindowDimensions();
  const [panel, setPanel] = useState(null);
  const [phase, setPhase] = useState("idle");
  const [statusText, setStatusText] = useState("工位湖待命");
  const [caughtFish, setCaughtFish] = useState(null);
  const [caughtCount, setCaughtCount] = useState(0);
  const [score, setScore] = useState(0);
  const timers = useRef([]);
  const bob = useRef(new Animated.Value(0)).current;
  const fish = useRef(new Animated.Value(0)).current;
  const pulse = useRef(new Animated.Value(0)).current;

  const shell = useMemo(() => {
    const targetRatio = 390 / 844;
    let shellWidth = Math.min(width, 430);
    let shellHeight = shellWidth / targetRatio;
    if (shellHeight > height) {
      shellHeight = height;
      shellWidth = shellHeight * targetRatio;
    }
    return {
      width: shellWidth,
      height: shellHeight
    };
  }, [width, height]);

  const imageFrame = useMemo(() => getImageFrame(shell.width, shell.height), [shell.width, shell.height]);

  useEffect(() => {
    const bobLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(bob, { toValue: 1, duration: 1500, useNativeDriver: true }),
        Animated.timing(bob, { toValue: 0, duration: 1500, useNativeDriver: true })
      ])
    );
    const fishLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(fish, { toValue: 1, duration: 2200, useNativeDriver: true }),
        Animated.timing(fish, { toValue: 0, duration: 2200, useNativeDriver: true })
      ])
    );
    const pulseLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, { toValue: 1, duration: 1200, useNativeDriver: true }),
        Animated.timing(pulse, { toValue: 0, duration: 1200, useNativeDriver: true })
      ])
    );
    bobLoop.start();
    fishLoop.start();
    pulseLoop.start();
    return () => {
      bobLoop.stop();
      fishLoop.stop();
      pulseLoop.stop();
      timers.current.forEach(clearTimeout);
    };
  }, [bob, fish, pulse]);

  const openPanel = (id) => {
    if (id === "shop" || id === "glory" || id === "bag") {
      setPanel(id);
      return;
    }
    if (id === "startFishing" || id === "mouseCast") {
      castLine();
      return;
    }
    if (id === "mouseReel") {
      reelLine();
      return;
    }
    setPanel(id);
  };

  const castLine = () => {
    timers.current.forEach(clearTimeout);
    timers.current = [];
    if (phase === "waiting" || phase === "biting") {
      reelLine();
      return;
    }
    setPhase("casting");
    setStatusText("抛线中");
    timers.current.push(setTimeout(() => {
      setPhase("waiting");
      setStatusText("等待鱼咬钩");
    }, 650));
    timers.current.push(setTimeout(() => {
      setPhase("biting");
      setStatusText("鱼咬钩了，点击鼠标下半区收线");
    }, 2600));
  };

  const reelLine = () => {
    if (phase !== "waiting" && phase !== "biting" && phase !== "casting") {
      setStatusText("先点击开始钓鱼或抛线");
      setPanel("moyuStatus");
      return;
    }
    setPhase("reeling");
    setStatusText("收线中");
    timers.current.push(setTimeout(() => {
      const nextFish = fishList[Math.min(fishList.length - 1, Math.floor(Math.random() * fishList.length))];
      setCaughtFish(nextFish);
      setCaughtCount((value) => value + 1);
      setScore((value) => value + nextFish.score);
      setPhase("caught");
      setStatusText(`获得 ${nextFish.name}`);
      setPanel("caught");
    }, 1100));
  };

  const closePanel = () => setPanel(null);
  const genericTitle = MODAL_TITLES[panel] || "上班摸鱼";

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="light-content" />
      <View style={[styles.shell, shell]}>
        <ImageBackground source={backgroundImage} resizeMode={BACKGROUND_FIT} style={styles.background}>
          <MotionLayer imageFrame={imageFrame} bob={bob} fish={fish} pulse={pulse} phase={phase} />
          {HOTSPOTS.map((hotspot) => (
            <HotspotButton
              key={hotspot.id}
              label={hotspot.label}
              style={mapRect(hotspot.rect, imageFrame)}
              onPress={() => openPanel(hotspot.id)}
            />
          ))}
        </ImageBackground>
      </View>

      <ShopModal visible={panel === "shop"} onClose={closePanel} />
      <GloryModal visible={panel === "glory"} onClose={closePanel} caughtCount={caughtCount} score={score} />
      <BagModal visible={panel === "bag"} onClose={closePanel} />
      <GameModal visible={Boolean(panel && !["shop", "glory", "bag"].includes(panel))} title={genericTitle} onClose={closePanel}>
        <GenericPanel panel={panel} statusText={statusText} caughtFish={caughtFish} score={score} caughtCount={caughtCount} />
      </GameModal>
    </SafeAreaView>
  );
}

function MotionLayer({ imageFrame, bob, fish, pulse, phase }) {
  const bobberRect = mapRect(ANIMATION_ANCHORS.bobber, imageFrame);
  const fishLeftRect = mapRect(ANIMATION_ANCHORS.seaFishLeft, imageFrame);
  const fishRightRect = mapRect(ANIMATION_ANCHORS.seaFishRight, imageFrame);
  const lineRect = mapRect(ANIMATION_ANCHORS.line, imageFrame);
  const bobTranslate = bob.interpolate({ inputRange: [0, 1], outputRange: [0, 7] });
  const fishTranslate = fish.interpolate({ inputRange: [0, 1], outputRange: [0, -12] });
  const pulseScale = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.7, 1.35] });
  const pulseOpacity = pulse.interpolate({ inputRange: [0, 1], outputRange: [0.36, 0.04] });
  const lineOpacity = phase === "casting" || phase === "waiting" || phase === "biting" || phase === "reeling" ? 0.58 : 0.2;

  return (
    <View pointerEvents="none" style={StyleSheet.absoluteFill}>
      <Animated.View style={[styles.bobberPulse, bobberRect, { opacity: pulseOpacity, transform: [{ scale: pulseScale }, { translateY: bobTranslate }] }]} />
      <Animated.View style={[styles.fishRipple, fishLeftRect, { transform: [{ translateY: fishTranslate }] }]} />
      <Animated.View style={[styles.fishRipple, fishRightRect, { transform: [{ translateY: fishTranslate }] }]} />
      <Animated.View style={[styles.lineGlow, { left: lineRect.left, top: lineRect.top, height: lineRect.height, opacity: lineOpacity }]} />
    </View>
  );
}

function GenericPanel({ panel, statusText, caughtFish, score, caughtCount }) {
  if (panel === "caught" && caughtFish) {
    return (
      <View style={styles.panelTextWrap}>
        <Text style={styles.bigText}>{caughtFish.name}</Text>
        <Text style={styles.text}>稀有度：{caughtFish.rarity}</Text>
        <Text style={styles.text}>售价：{caughtFish.price} 摸鱼币</Text>
        <Text style={styles.text}>积分：+{caughtFish.score}</Text>
      </View>
    );
  }

  const content = {
    accountCenter: ["玩家：FishingPro", "等级：职场小白", `累计鱼获：${caughtCount} 条`],
    gameGuide: ["点击透明热区操作首页。", "开始钓鱼后等待鱼咬钩。", "鱼咬钩后点击鼠标下半区收线。"],
    gameHall: ["游戏大厅入口已接入。", "后续可挂载更多小游戏。"],
    moyuStatus: [`当前状态：${statusText}`, `累计积分：${score}`],
    lakeMap: ["当前地图：办公室窗外海面。", "后续可切换湖畔、茶水间、会议室等地图。"],
    wallet: ["摸鱼币：80", "钻石：0", "充值入口后续接平台钱包。"],
    logout: ["已触发退出登录入口。", "后续接账号系统的登出 API。"],
    nameplate: ["上班摸鱼", "ID：FishingPro", "这里展示账号资料。"],
    taskBoard: ["钓到 10 条鱼：0/10", "升级线到 10 级：6/10", "邀请 3 位好友：1/3"],
    fishBook: fishList.map((fish) => `${fish.name} · ${fish.rarity} · ${fish.price}币`)
  }[panel] || [statusText];

  return (
    <View style={styles.panelTextWrap}>
      {content.map((line) => (
        <Text key={line} style={styles.text}>{line}</Text>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#071320"
  },
  shell: {
    overflow: "hidden",
    backgroundColor: "#06111d"
  },
  background: {
    flex: 1
  },
  bobberPulse: {
    position: "absolute",
    borderRadius: 999,
    borderWidth: 2,
    borderColor: "rgba(255,255,255,.82)",
    backgroundColor: "rgba(255,255,255,.12)"
  },
  fishRipple: {
    position: "absolute",
    borderRadius: 999,
    borderWidth: 2,
    borderColor: "rgba(255,255,255,.32)",
    backgroundColor: "rgba(255,255,255,.08)"
  },
  lineGlow: {
    position: "absolute",
    width: 2,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,.76)",
    transform: [{ rotate: "-18deg" }]
  },
  panelTextWrap: {
    gap: 10
  },
  bigText: {
    color: "#ffe277",
    fontSize: 26,
    fontWeight: "900"
  },
  text: {
    color: "#f3fbff",
    fontSize: 15,
    fontWeight: "800",
    lineHeight: 22
  }
});
