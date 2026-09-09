<script setup lang="ts">
useHead({ title: 'The road north · Embercrown' })

const { campaign, acts, dragon, hasStarted } = useCampaign()
</script>

<template>
  <div class="space-y-5">
    <div>
      <p class="rune">The road north</p>
      <h1 class="mt-1 text-2xl">Riverwatch to the Ember Throne</h1>
      <p v-if="campaign" class="mt-1.5 text-sm text-parchment-500">
        {{ formatDate(campaign.starts_on) }} — {{ formatDate(campaign.ends_on) }}
      </p>
    </div>

    <p v-if="!hasStarted" class="font-chronicle text-parchment-400">
      Five lieutenants stand between the company and the mountain. Each is
      weighed at the end of its own act; the wyrm is weighed on everything, on
      the fifteenth of December, before the longest night.
    </p>

    <!-- The five acts, joined by the road. -->
    <ol class="relative space-y-3 pl-0">
      <li v-for="boss in acts" :key="boss.id">
        <CampaignMapNode :boss="boss" />
      </li>
    </ol>

    <div v-if="dragon" class="relative">
      <div class="mb-3 flex items-center gap-3">
        <div class="h-px flex-1 bg-ash-700" />
        <span class="rune">and at the summit</span>
        <div class="h-px flex-1 bg-ash-700" />
      </div>
      <CampaignMapNode :boss="dragon" />
      <p class="mt-2 text-center text-[0.6875rem] text-parchment-500">
        The wyrm tests all six. Every lieutenant that escapes makes her heavier.
      </p>
    </div>
  </div>
</template>
