<script setup>
import { AlertDialogRoot } from "reka-ui";

const props = defineProps({
  open: { type: Boolean, required: false },
  defaultOpen: { type: Boolean, required: false },
});

const emit = defineEmits(["update:open"]);
</script>

<template>
  <AlertDialogRoot
    :open="open"
    :default-open="defaultOpen"
    @update:open="emit('update:open', $event)"
  >
    <slot />
  </AlertDialogRoot>
</template>
