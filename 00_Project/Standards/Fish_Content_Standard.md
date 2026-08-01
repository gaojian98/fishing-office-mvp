# Fish Content Standard V1.0

本标准用于约束《上班摸鱼》所有鱼类内容。以后新增鱼类必须先满足内容标准，再进入 JSON 配置。

## 鱼类八问标准

每条鱼必须回答：

1. 它是谁？
2. 它住在哪里？
3. 它什么时候出现？
4. 它喜欢什么？
5. 它害怕什么？
6. 它是什么性格？
7. 它有什么故事？
8. 如果它会说话，第一次会对玩家说什么？

## 必填 JSON 字段

每条鱼必须包含：

- id
- name
- nickname
- rarity
- habitat
- favoriteTime
- favoriteWeather
- favoriteBait
- fear
- personality
- description
- story
- firstDialogue
- catchReaction
- waitDialogues
- value
- weightRange
- baitRequired
- nextBaitTarget

## 内容合格规则

以后任何鱼缺少上述字段，都视为内容不合格。

鱼不是资源。
鱼是第二世界里的居民。
每条鱼都应该拥有性格、栖息地、害怕的东西、等待中的对白和一次值得被记住的相遇。
