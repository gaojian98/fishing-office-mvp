import React from "react";
import { StyleSheet, Text, View } from "react-native";
import GameModal from "./GameModal";
import { bagItems } from "../data/gameData";

export default function BagModal({ visible, onClose }) {
  return (
    <GameModal visible={visible} title="背包" onClose={onClose}>
      <View style={styles.section}>
        <Text style={styles.heading}>渔具与鱼饵</Text>
        <View style={styles.grid}>
          {bagItems.map((item) => (
            <View key={item} style={styles.item}>
              <Text style={styles.itemName}>{item}</Text>
              <Text style={styles.itemMeta}>可用</Text>
            </View>
          ))}
        </View>
      </View>
    </GameModal>
  );
}

const styles = StyleSheet.create({
  section: {
    gap: 10
  },
  heading: {
    color: "#dff8ff",
    fontSize: 15,
    fontWeight: "900"
  },
  grid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8
  },
  item: {
    width: "47.6%",
    minHeight: 58,
    padding: 10,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,.2)",
    backgroundColor: "rgba(255,255,255,.12)"
  },
  itemName: {
    color: "#fff",
    fontSize: 13,
    fontWeight: "900"
  },
  itemMeta: {
    marginTop: 4,
    color: "#a7ecff",
    fontSize: 11,
    fontWeight: "800"
  }
});
