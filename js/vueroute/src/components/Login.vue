<template>
    <div>
        <p>Login</p>
        <p>My value is worth {{ value.x }}</p>
    </div>
</template>

<script>
export default {
    props: [ 'value' ]
}
</script>