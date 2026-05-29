App({
  globalData: {
    appName: '云暮星霞',
    storageKeys: {
      orders: 'ymxx_orders'
    }
  },

  getOrders() {
    return wx.getStorageSync(this.globalData.storageKeys.orders) || [];
  },

  saveOrder(order) {
    const orders = this.getOrders();
    orders.unshift(order);
    wx.setStorageSync(this.globalData.storageKeys.orders, orders);
    return orders;
  }
});
