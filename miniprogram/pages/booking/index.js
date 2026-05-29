const app = getApp();
const {
  companions,
  servicePackages,
  timeSlots,
  voiceChannels
} = require('../../utils/data');

Page({
  data: {
    companion: null,
    servicePackages,
    timeSlots,
    voiceChannels,
    selectedPackageId: servicePackages[0].id,
    selectedPackage: servicePackages[0],
    durationOptions: [1, 2, 3, 4],
    durationHours: 2,
    timeIndex: 0,
    voiceIndex: 0,
    note: '',
    totalPrice: 0
  },

  onLoad(options) {
    const companion = companions.find((item) => item.id === options.id) || companions[0];
    this.setData({
      companion,
      totalPrice: companion.price * this.data.durationHours
    });
  },

  selectPackage(event) {
    const { id } = event.currentTarget.dataset;
    const selectedPackage = servicePackages.find((item) => item.id === id);
    this.setData({
      selectedPackageId: id,
      selectedPackage
    });
  },

  selectDuration(event) {
    const durationHours = Number(event.currentTarget.dataset.hour);
    this.setData({
      durationHours,
      totalPrice: this.data.companion.price * durationHours
    });
  },

  changeTime(event) {
    this.setData({
      timeIndex: Number(event.detail.value)
    });
  },

  changeVoice(event) {
    this.setData({
      voiceIndex: Number(event.detail.value)
    });
  },

  inputNote(event) {
    this.setData({
      note: event.detail.value
    });
  },

  submitOrder() {
    const order = {
      id: String(Date.now()).slice(-8),
      companion: this.data.companion,
      servicePackage: this.data.selectedPackage,
      durationHours: this.data.durationHours,
      timeLabel: timeSlots[this.data.timeIndex],
      voiceChannel: voiceChannels[this.data.voiceIndex],
      note: this.data.note.trim(),
      totalPrice: this.data.totalPrice,
      status: '待确认',
      createdAt: new Date().toLocaleString()
    };

    app.saveOrder(order);
    wx.showToast({
      title: '预约已提交',
      icon: 'success'
    });

    setTimeout(() => {
      wx.switchTab({
        url: '/pages/orders/index'
      });
    }, 500);
  }
});
