const { companions, servicePackages } = require('../../utils/data');

Page({
  data: {
    servicePackages,
    featuredCompanions: companions.slice(0, 3)
  },

  goBooking(event) {
    const { id } = event.currentTarget.dataset;
    wx.navigateTo({
      url: `/pages/booking/index?id=${id}`
    });
  },

  goCompanions() {
    wx.switchTab({
      url: '/pages/companions/index'
    });
  }
});
