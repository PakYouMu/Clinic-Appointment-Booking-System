<script setup>
import { cn } from "@/lib/utils";
import { AlertDialogDescription as AlertDialogDescriptionPrimitive } from "reka-ui";

const props = defineProps({
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});
</script>

<template>
  <AlertDialogDescriptionPrimitive
    :class="cn('text-sm text-muted-foreground', props.class)"
  >
    <slot />
  </AlertDialogDescriptionPrimitive>
</template>
