import React from "react";
import { StyleSheet, Text, View } from "react-native";
import GameModal from "./GameModal";
import { fishList } from "../data/gameData";

export default function GloryModal({ visible, onClose, caughtCount, score }) {
  return (
    <GameModal visible={visible} title="荣耀墙" onClose={onClose}>
      <View style={styles.wrap}>
        <View style={styles.left}>
          <View style={styles.stats}>
            <Stat value={caughtCount} label="鱼库记录" />
            <Stat value="2" label="养鱼" />
            <Stat value="1" label="卖鱼" />
            <Stat value="0" label="赠鱼" />
          </View>
          {fishList.map((fish, index) => (
            <View key={fish.name} style={styles.record}>
              <Text style={styles.recordName}>{fish.name}</Text>
              <Text style={styles.recordMeta}>{fish.rarity} · 累计 {index < caughtCount ? index + 1 : 0} 条</Text>
            </View>
          ))}
        </View>
        <View style={styles.right}>
          <Text style={styles.chartTitle}>积分 · 等级 · 时间</Text>
          <View style={styles.chart}>
            {[18, 42, 58, 72, Math.min(92, 46 + score / 6)].map((top, index) => (
              <View key={index} style={[styles.point, { left: `${12 + index * 20}%`, bottom: `${top}%` }]} />
            ))}
            <View style={[styles.line, { bottom: "24%", transform: [{ rotate: "-12deg" }] }]} />
            <View style={[styles.line, { bottom: "42%", transform: [{ rotate: "-8deg" }] }]} />
            <View style={[styles.line, { bottom: "58%", transform: [{ rotate: "6deg" }] }]} />
            <View style={[styles.line, { bottom: "68%", transform: [{ rotate: "-2deg" }] }]} />
            <Text style={styles.axisY}>积分</Text>
            <Text style={styles.axisX}>时间</Text>
          </View>
          <Text style={styles.level}>职场小白 · {score} 分</Text>
        </View>
      </View>
    </GameModal>
  );
}

function Stat({ value, label }) {
  return (
    <View style={styles.stat}>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statLabel}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: "row",
    gap: 10
  },
  left: {
    flex: 1,
    gap: 7
  },
  right: {
    flex: 1,
    gap: 8
  },
  stats: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 6
  },
  stat: {
    width: "47%",
    padding: 7,
    borderRadius: 10,
    backgroundColor: "rgba(255,255,255,.14)"
  },
  statValue: {
    color: "#ffe277",
    fontSize: 18,
    fontWeight: "900"
  },
  statLabel: {
    color: "#e8f7ff",
    fontSize: 10,
    fontWeight: "800"
  },
  record: {
    padding: 7,
    borderRadius: 10,
    backgroundColor: "rgba(255,255,255,.1)"
  },
  recordName: {
    color: "#fff",
    fontSize: 13,
    fontWeight: "900"
  },
  recordMeta: {
    color: "#cae8ff",
    fontSize: 10,
    fontWeight: "700"
  },
  chartTitle: {
    color: "#fff",
    fontSize: 13,
    fontWeight: "900"
  },
  chart: {
    height: 178,
    borderRadius: 14,
    backgroundColor: "rgba(4, 26, 54, .62)",
    overflow: "hidden"
  },
  point: {
    position: "absolute",
    width: 9,
    height: 9,
    borderRadius: 99,
    backgroundColor: "#66ffb5"
  },
  line: {
    position: "absolute",
    left: "16%",
    width: "64%",
    height: 3,
    borderRadius: 3,
    backgroundColor: "rgba(102,255,181,.76)"
  },
  axisY: {
    position: "absolute",
    left: 8,
    top: 8,
    color: "#cbefff",
    fontSize: 10,
    fontWeight: "800"
  },
  axisX: {
    position: "absolute",
    right: 8,
    bottom: 8,
    color: "#cbefff",
    fontSize: 10,
    fontWeight: "800"
  },
  level: {
    color: "#ffe277",
    fontSize: 13,
    fontWeight: "900"
  }
});
