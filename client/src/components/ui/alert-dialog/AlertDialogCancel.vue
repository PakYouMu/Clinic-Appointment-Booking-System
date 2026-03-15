<script setup>
import { cn } from "@/lib/utils";
import { AlertDialogCancel as AlertDialogCancelPrimitive } from "reka-ui";
import { buttonVariants } from "@/components/ui/button";

const props = defineProps({
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});
</script>

<template>
  <AlertDialogCancelPrimitive
    :class="cn(buttonVariants({ variant: 'outline' }), props.class)"
  >
    <slot />
  </AlertDialogCancelPrimitive>
</template>
