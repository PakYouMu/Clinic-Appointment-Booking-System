<script setup>
import { cn } from "@/lib/utils";
import { AlertDialogTitle as AlertDialogTitlePrimitive } from "reka-ui";

const props = defineProps({
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});
</script>

<template>
  <AlertDialogTitlePrimitive
    :class="cn('text-lg font-semibold', props.class)"
  >
    <slot />
  </AlertDialogTitlePrimitive>
</template>
