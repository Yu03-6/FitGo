const app = getApp();

Page({
  data: {
    orders: []
  },

  onShow() {
    this.setData({
      orders: app.getOrders()
    });
  },

  goCompanions() {
    wx.switchTab({
      url: '/pages/companions/index'
    });
  },

  clearOrders() {
    wx.showModal({
      title: '清空订单',
      content: '确定要清空本机保存的预约订单吗？',
      success: (result) => {
        if (!result.confirm) {
          return;
        }
        wx.setStorageSync(app.globalData.storageKeys.orders, []);
        this.setData({ orders: [] });
      }
    });
  }
});
