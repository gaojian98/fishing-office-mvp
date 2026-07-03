import React from "react";
import { Modal, Pressable, StyleSheet, Text, View } from "react-native";

export default function GameModal({ visible, title, children, onClose }) {
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View style={styles.mask}>
        <Pressable style={styles.backdrop} onPress={onClose} />
        <View style={styles.panel}>
          <View style={styles.header}>
            <Text style={styles.title}>{title}</Text>
            <Pressable accessibilityRole="button" accessibilityLabel="关闭" onPress={onClose} style={styles.close}>
              <Text style={styles.closeText}>×</Text>
            </Pressable>
          </View>
          <View style={styles.body}>{children}</View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  mask: {
    flex: 1,
    justifyContent: "center",
    paddingHorizontal: 22,
    backgroundColor: "rgba(3, 12, 24, .5)"
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject
  },
  panel: {
    maxHeight: "78%",
    borderRadius: 24,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,.32)",
    backgroundColor: "rgba(8, 42, 78, .92)",
    overflow: "hidden"
  },
  header: {
    minHeight: 54,
    paddingLeft: 18,
    paddingRight: 8,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "rgba(255,255,255,.1)"
  },
  title: {
    color: "#fff",
    fontSize: 20,
    fontWeight: "900"
  },
  close: {
    width: 44,
    height: 44,
    alignItems: "center",
    justifyContent: "center"
  },
  closeText: {
    color: "#fff",
    fontSize: 30,
    fontWeight: "800",
    lineHeight: 32
  },
  body: {
    padding: 16
  }
});
