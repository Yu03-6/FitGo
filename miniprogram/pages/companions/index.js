const { companions, filterTags } = require('../../utils/data');

Page({
  data: {
    filterTags,
    activeTag: '全部',
    companions
  },

  selectTag(event) {
    const { tag } = event.currentTarget.dataset;
    const nextCompanions = tag === '全部'
      ? companions
      : companions.filter((item) => item.tags.includes(tag));

    this.setData({
      activeTag: tag,
      companions: nextCompanions
    });
  },

  goBooking(event) {
    const { id } = event.currentTarget.dataset;
    wx.navigateTo({
      url: `/pages/booking/index?id=${id}`
    });
  }
});
