<template>
  <div class="c-Publicity">
    <el-carousel
      height="50px"
      :autoplay="true"
      indicator-position="none"
      arrow="never"
      :interval="3000"
    >
      <el-carousel-item v-for="item in message" :key="item.key">
        <div class="item" :class="{ actiname: item.key === 0 }">
          <span v-if="item.title" class="title"> {{ item.title }}</span>
          <span v-if="item.value" class="value">
            {{ item.value }}
          </span>
        </div>
      </el-carousel-item>
    </el-carousel>
  </div>
</template>
<script>
import { conversionCategoryName } from '@/helper/index';

export default {
  name: 'Publicity',
  computed: {
    config() {
      //	{"6":10,"7":10,"8":10,"9":10,"10":10,"name":"大訊/展訊尾牙抽奖","number":"140","firstPrize":1}
      return this.$store.state.config;
    },
    listUser:{
      get(){ return this.$store.state.list;},
      //set(val){this.$store.commit('setList',val);}
    },
    result() {
      //	{"6":[12,65,20,137,98,23,49,5,27],"firstPrize":[]}
      return this.$store.state.result;
    },
    message() {
      const { result, config } = this;
      const fields = Object.keys(config);

      let message = [{ key: 0, title: config.name }];
      fields.forEach((item, index) => {
        let label = conversionCategoryName(item);
        
        if (result[item] && config[item] > 0) {
          
          let resultvalue='';
          result[item].forEach((item)=>{
            resultvalue+=this.listUser.find(x=>x.key===item).name +'、';
          });

          message.push({
            key: index + 1,
            title: `${label}抽獎結果:`,
            value: `${
              //{{ listUser.length>0?listUser.find(x=>x.key===data)==undefined?'':listUser.find(x=>x.key===data).name:'' }}
              result[item].length > 0 ? resultvalue : '暫未抽取'
              //result[item].length > 0 ? result[item].join('、') : '暫未抽取'
            }`
          });
        }
      });

      return message;
    }
  }
};
</script>
<style lang="scss">
.c-Publicity {
  height: 100%;
  // width: 1000px;
  background-color: rgba(255, 255, 255, 0.1);
  margin: 0 auto;
  position: relative;
  overflow: hidden;
  .el-carousel {
    width: 80vw;
    margin: 0 auto;
  }
  .item {
    text-align: center;
    color: #fff;
    font-size: 16px;
    .title {
      color: #ccc;
    }
    .value {
      margin-left: 10px;
    }
    &.actiname {
      .title {
        color: red;
        font-size: 20px;
      }
    }
  }
}
</style>
