<template>
  <div id="tool">
    <el-button @click="startHandler" type="primary" size="medium" class="btnprimary">{{
      running ? '停止' : '開始'
    }}</el-button>
    <el-button size="mini" @click="showRemoveoptions = true">
      重置
    </el-button>
    <el-button size="mini" @click="showImport = true">
      導入名單
    </el-button>
    <el-button size="mini" @click="sequenceDownload">
      匯出中獎名單
    </el-button>
    <!-- <el-button size="mini" @click="showImportphoto = true" >
      导入照片
    </el-button> -->
    <el-dialog
      :append-to-body="true"
      :visible.sync="showSetwat"
      class="setwat-dialog"
      width="400px"
    >
      <el-form ref="form" :model="form" label-width="80px" size="mini">
        <el-form-item label="抽取獎項">
          <el-select v-model="form.category" placeholder="請選取本次抽取的獎項">
            <el-option
              :label="item.label"
              :value="item.value"
              v-for="(item, index) in categorys"
              :key="index"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label=" " v-if="form.category">
          <span>
            共&nbsp;
            <span class="colorred">{{ config[form.category] }}</span>
            &nbsp;名
          </span>
          <span :style="{ marginLeft: '20px' }">
            剩下&nbsp;
            <span class="colorred">{{ remain }}</span>
            &nbsp;名
          </span>
        </el-form-item>

        <el-form-item label="抽取方式">
          <el-select v-model="form.mode" placeholder="請選取本次抽取方式">
            <el-option label="抽1人" :value="1"></el-option>
            <el-option label="抽5人" :value="5"></el-option>
            <el-option label="抽10人" :value="10"></el-option>
            <el-option label="一次抽取完" :value="0"></el-option>
            <el-option label="自定義" :value="99"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="抽取人數" v-if="form.mode === 99">
          <el-input
            v-model="form.qty"
            type="number"
            :clearable="true"
            :min="1"
            :max="remain ? remain : 100"
            :step="1"
          ></el-input>
        </el-form-item>

        <el-form-item label="全員參與">
          <el-switch v-model="form.allin"></el-switch>
          <span :style="{ fontSize: '12px' }">
            (開啟後將在全體成員[無論有無中獎]中抽獎)
          </span>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="onSubmit">立即抽獎</el-button>
          <el-button @click="showSetwat = false">取消</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>

    <el-dialog
      :append-to-body="true"
      :visible.sync="showImport"
      class="import-dialog"
      width="400px"
    >
      <el-input
        type="textarea"
        :rows="10"
        placeholder="請輸入對應的號碼和名單(可直接從excel覆制)，格式(號碼 名字)，導入的名單將代替號碼顯示在抽獎中。如：
1 張三
2 李四
3 王五
				"
        v-model="listStr"
      ></el-input>
      <div class="footer">
        <el-button size="mini" type="primary" @click="transformList"
          >确定</el-button
        >
        <el-button size="mini" @click="showImport = false">取消</el-button>
      </div>
    </el-dialog>
    <Importphoto
      :visible.sync="showImportphoto"
      @getPhoto="$emit('getPhoto')"
    ></Importphoto>

    <el-dialog
      :visible.sync="showRemoveoptions"
      width="300px"
      class="c-removeoptions"
      :append-to-body="true"
    >
    <el-form ref="form" :model="removeInfo" label-width="80px" size="mini">
        <el-form-item label="重置選項">
          <el-radio-group v-model="removeInfo.type">
            <el-radio border :label="0">重置全部數據</el-radio>
            <el-radio border :label="1">重置抽獎配置</el-radio>
            <el-radio border :label="2">重置名單</el-radio>
            <!-- <el-radio border :label="3">重置照片</el-radio> -->
            <el-radio border :label="4">重置抽獎結果</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="resetConfig">確定重置</el-button>
          <el-button @click="showRemoveoptions = false">取消</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script>
import {
  clearData,
  removeData,
  configField,
  listField,
  resultField,
  conversionCategoryName
} from '@/helper/index';
import Importphoto from './Importphoto';
import { database, DB_STORE_NAME } from '@/helper/db';

export default {
  props: {
    running: Boolean,
    closeRes: Function
  },
  computed: {
    config: {
      get() {
        return this.$store.state.config;
      }
    },
    remain() {
      return (
        this.config[this.form.category] -
        (this.result[this.form.category]
          ? this.result[this.form.category].length
          : 0)
      );
    },
    result() {
      return this.$store.state.result;
    },
    
    categorys() {
      const options = [];
      for (const key in this.config) {
        if (this.config.hasOwnProperty(key)) {
          const item = this.config[key];
          if (item > 0) {
            let name = conversionCategoryName(key);
            name &&
              options.push({
                label: name,
                value: key
              });
          }
        }
      }
      return options;
    }
  },
  components: { Importphoto },
  data() {
    return {
      showSetwat: false,
      showImport: false,
      showImportphoto: false,
      showRemoveoptions: false,
      removeInfo: { type: 0 },
      form: {
        category: '',
        mode: 1,
        qty: 1,
        allin: false
      },
      listStr: ''
    };
  },
  watch: {
    showRemoveoptions(v) {
      if (!v) {
        this.removeInfo.type = 0;
      }
    }
  },
  methods: {
    resetConfig() {
      const type = this.removeInfo.type;
      this.$confirm('此操作將重置所選數據，是否繼續?', '提示', {
        confirmButtonText: '確定',
        cancelButtonText: '取消',
        type: 'warning'
      })
        .then(() => {
          switch (type) {
            case 0:
              clearData();
              this.$store.commit('setClearStore');
              database.clear(DB_STORE_NAME);
              break;
            case 1:
              removeData(configField);
              this.$store.commit('setClearConfig');
              break;
            case 2:
              removeData(listField);
              this.$store.commit('setClearList');
              break;
            case 3:
              database.clear(DB_STORE_NAME);
              this.$store.commit('setClearPhotos');
              break;
            case 4:
              removeData(resultField);
              this.$store.commit('setClearResult');
              break;
            default:
              break;
          }

          this.closeRes && this.closeRes();

          this.showRemoveoptions = false;
          this.$message({
            type: 'success',
            message: '重置成功!'
          });

          this.$nextTick(() => {
            this.$emit('resetConfig');
          });
        })
        .catch(() => {
          this.$message({
            type: 'info',
            message: '已取消'
          });
        });
    },
    onSubmit() {
      if (!this.form.category) {
        return this.$message.error('請選擇本次抽取的獎項');
      }
      if (this.remain <= 0) {
        return this.$message.error('該獎項剩余人數不足');
      }
      if (this.form.mode === 99) {
        if (this.form.qty <= 0) {
          return this.$message.error('必須輸入本次抽取人數');
        }
        if (this.form.qty > this.remain) {
          return this.$message.error('本次抽獎人數已超過本獎項的剩余人數');
        }
      }
      if (this.form.mode === 1 || this.form.mode === 5|| this.form.mode === 10) {
        if (this.form.mode > this.remain) {
          return this.$message.error('本次抽獎人數已超過本獎項的剩余人數');
        }
      }
      this.showSetwat = false;
      this.$emit(
        'toggle',
        Object.assign({}, this.form, { remain: this.remain })
      );
    },
    startHandler() {
      this.$emit('toggle');
      if (!this.running) {
        this.showSetwat = true;
      }
    },
    transformList() {
      const { listStr } = this;
      if (!listStr) {
        this.$message.error('沒有數據');
      }
      const list = [];
      const rows = listStr.split('\n');
      if (rows && rows.length > 0) {
        rows.forEach(item => {
          const rowList = item.split(/\t|\s/);
          if (rowList.length >= 2) {
            const key = Number(rowList[0].trim());
            const name = rowList[1].trim();
            key &&
              list.push({
                key,
                name
              });
          }
        });
      }
      this.$store.commit('setList', list);

      this.$message({
        message: '保存成功',
        type: 'success'
      });
      this.showImport = false;
      this.$nextTick(() => {
        this.$emit('resetConfig');
      });
    },
    sequenceDownload() {
      let content='';
      const result=this.$store.state.result;
      const list=this.$store.state.list;
      //console.log(`list:${list.find(x=>x.key===58).name}`);
      for (const key in result) {
        
        //獎項名稱
        let name = conversionCategoryName(key); 
        content+=name + '\r\n';
        // 中獎內容
        const element = this.result[key]; 
        if(element.length>0){
          Object.keys(element).forEach(item=>{
            const resultuser=Number(element[item]);
            content+=resultuser+':'+(list.length>0?list.find(x=>x.key===resultuser)==undefined?'':list.find(x=>x.key===resultuser).name:'') + '\r\n';
            //console.log(`resultuser:${resultuser},list.find(x=>x.key===resultuser):${list.find(x=>x.key===resultuser).name}`);
          });        
        }

        //const user=list.length>0?list.find(x=>x.key===element)==undefined?'':list.find(x=>x.key===element).name:'';
        //console.log(`element:${element},user:${user}`);
      }
      
      
      if(content==undefined||content==''){
          this.$message.warning('暂无导出数据！')
      }else{
        const element = document.createElement('a')
        element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(content))
        element.setAttribute('download', 'result')
        element.style.display = 'none'
        element.click()
      }
    }
  }
};
</script>
<style lang="scss">
#tool {
  z-index: 10;
  position: fixed;
  // width: 60px;
  top: 50%;
  right: 20px;
  transform: translateY(-50%);
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  .el-button + .el-button {
    margin-top: 20px;
    margin-left: 0px;
  }
}
.setwat-dialog {
  .colorred {
    color: red;
    font-weight: bold;
  }
}
.import-dialog {
  .footer {
    height: 50px;
    line-height: 50px;
    text-align: center;
  }
}
.c-removeoptions {
  .el-dialog {
    height: 290px;
  }
  .el-radio.is-bordered + .el-radio.is-bordered {
    margin-left: 0px;
  }
  .el-radio.is-bordered {
    margin-bottom: 10px;
  }
}
.btnprimary{
  padding: 20px 20px !important;
  font-size: 40px !important;
  border-radius: 30px !important;
  margin-bottom: 60px !important;
  //animation: blinkAndChangeColor 5s linear infinite;
}
@keyframes blinkAndChangeColor {
    0%, 100% { 
        opacity: 1; 
        background-color: 	#003D79; 
        color: #fff;
    }
    50% { 
        opacity: 0.15; 
        background-color: #842B00;
        color: #000;
    }
}
</style>
