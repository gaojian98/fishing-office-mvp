import React from "react";
import { StyleSheet, Text, View } from "react-native";
import GameModal from "./GameModal";
import { shopItems } from "../data/gameData";

export default function ShopModal({ visible, onClose }) {
  return (
    <GameModal visible={visible} title="渔具商店" onClose={onClose}>
      <View style={styles.shelf}>
        {shopItems.map((item, index) => (
          <View key={item} style={styles.cell}>
            <Text style={styles.icon}>{index % 3 === 0 ? "🎣" : index % 3 === 1 ? "🧵" : "🪱"}</Text>
            <Text style={styles.name}>{item}</Text>
            <Text style={styles.price}>{index < 4 ? "已拥有" : `${(index + 1) * 18} 摸鱼币`}</Text>
          </View>
        ))}
      </View>
    </GameModal>
  );
}

const styles = StyleSheet.create({
  shelf: {
    display: "flex",
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    padding: 10,
    borderRadius: 18,
    backgroundColor: "#8b572b"
  },
  cell: {
    width: "30.8%",
    minHeight: 92,
    alignItems: "center",
    justifyContent: "space-between",
    padding: 8,
    borderRadius: 12,
    backgroundColor: "#f2d09b"
  },
  icon: {
    fontSize: 24
  },
  name: {
    color: "#422612",
    fontSize: 12,
    fontWeight: "900",
    textAlign: "center"
  },
  price: {
    width: "100%",
    paddingVertical: 3,
    borderRadius: 6,
    overflow: "hidden",
    color: "#5b330f",
    backgroundColor: "#ffd36b",
    fontSize: 10,
    fontWeight: "900",
    textAlign: "center"
  }
});
