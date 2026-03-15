<script setup>
import { cn } from "@/lib/utils";
import { AlertDialogAction as AlertDialogActionPrimitive } from "reka-ui";
import { buttonVariants } from "@/components/ui/button";

const props = defineProps({
  variant: { type: null, required: false },
  size: { type: null, required: false },
  class: {
    type: [Boolean, null, String, Object, Array],
    required: false,
    skipCheck: true,
  },
});
</script>

<template>
  <AlertDialogActionPrimitive
    :class="cn(buttonVariants({ variant, size }), props.class)"
  >
    <slot />
  </AlertDialogActionPrimitive>
</template>
