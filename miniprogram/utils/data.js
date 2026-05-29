const servicePackages = [
  {
    id: 'escort',
    title: '摸金护航',
    description: '规划撤离路线，带搜高价值物资。',
    icon: '💎',
    color: '#00A6A6'
  },
  {
    id: 'rank',
    title: '排位上分',
    description: '补位指挥、控图报点、稳定上分。',
    icon: '🏅',
    color: '#FF8A5B'
  },
  {
    id: 'coach',
    title: '枪法教学',
    description: '灵敏度建议、架枪点位与复盘。',
    icon: '🎯',
    color: '#5E5CE6'
  },
  {
    id: 'fun',
    title: '娱乐陪伴',
    description: '轻松聊天开黑，主打氛围不压力。',
    icon: '💜',
    color: '#E85D9E'
  }
];

const companions = [
  {
    id: 'mu-ting-feng',
    name: '暮听风',
    avatar: '暮',
    role: '烽火地带指挥 / 航天基地熟练',
    bio: '擅长路线规划和临场指挥，适合想稳撤、想摸金的新老玩家。',
    tags: ['摸金带路', '战术教学'],
    rating: '4.9',
    price: 58,
    online: true,
    color: '#5E5CE6',
    colorAccent: '#00C2FF'
  },
  {
    id: 'xing-ye-mao',
    name: '星野猫',
    avatar: '星',
    role: '女声陪玩 / 轻松娱乐局',
    bio: '声音温柔，气氛拉满，能打能聊，适合下班后放松开黑。',
    tags: ['情绪陪伴', '女声'],
    rating: '5.0',
    price: 66,
    online: true,
    color: '#E85D9E',
    colorAccent: '#FFB86B'
  },
  {
    id: 'yun-ji',
    name: '云霁',
    avatar: '云',
    role: '全面战场上分 / 突击位',
    bio: '主玩突击与支援，报点清晰，节奏主动，适合排位冲分。',
    tags: ['排位上分', '战术教学'],
    rating: '4.8',
    price: 52,
    online: true,
    color: '#00A6A6',
    colorAccent: '#6EE7B7'
  },
  {
    id: 'xia-ying',
    name: '霞影',
    avatar: '霞',
    role: '狙击架点 / 复盘教学',
    bio: '专注枪线、投掷物和转点细节，帮你把失误变成下一局优势。',
    tags: ['战术教学', '排位上分'],
    rating: '4.7',
    price: 48,
    online: false,
    color: '#FF8A5B',
    colorAccent: '#FFD166'
  }
];

const filterTags = ['全部', '摸金带路', '排位上分', '战术教学', '情绪陪伴', '女声'];
const timeSlots = ['今天 20:00', '今天 22:00', '明天 14:00', '明天 20:00', '周末黄金档'];
const voiceChannels = ['微信语音', 'QQ 语音', 'Discord', '游戏内语音'];

module.exports = {
  companions,
  filterTags,
  servicePackages,
  timeSlots,
  voiceChannels
};
