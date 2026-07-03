import React, { useRef } from "react";
import { Animated, Pressable, StyleSheet } from "react-native";

const SHOW_DEBUG_HOTSPOTS = false;

export default function HotspotButton({ label, style, onPress }) {
  const scale = useRef(new Animated.Value(1)).current;

  const animateTo = (value) => {
    Animated.spring(scale, {
      toValue: value,
      useNativeDriver: true,
      friction: 5,
      tension: 160
    }).start();
  };

  return (
    <Animated.View style={[styles.wrap, style, { transform: [{ scale }] }]}>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={label}
        onPress={onPress}
        onPressIn={() => animateTo(0.94)}
        onPressOut={() => animateTo(1)}
        style={styles.pressable}
      />
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    position: "absolute",
    borderRadius: 14,
    overflow: "hidden",
    borderWidth: SHOW_DEBUG_HOTSPOTS ? 1 : 0,
    borderColor: "rgba(255, 220, 0, .9)",
    backgroundColor: SHOW_DEBUG_HOTSPOTS ? "rgba(255, 220, 0, .18)" : "transparent"
  },
  pressable: {
    flex: 1,
    backgroundColor: "transparent"
  }
});
