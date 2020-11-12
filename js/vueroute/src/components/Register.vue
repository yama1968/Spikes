<template>
  <div>
    Register
    <p>Plus a {{ message }}</p>
    <p>Plus the value of record: {{ JSON.stringify(record) }}</p>
    <p>Plus I change it: {{ changeAndGetX() }}</p>
    <button v-on:click="$emit('add-ten')">Add ten to x</button>
  </div>
</template>

<script>
export default {
  props: ["message", "record"],
  methods: {
    changeAndGetX() {
      this.record.x++;
      return this.record.x;
    },
    addTen() {
      this.record.x += 10;
      console.log("Adding ten =>" + this.record.x);
    },
  },
};
</script>
