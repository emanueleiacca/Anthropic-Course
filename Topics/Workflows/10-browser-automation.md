---
title: Playbook - Browser automation, E2E, scraping
tags: [playwright, browser-automation, e2e, scraping, headless, mcp]
last_updated: 2026-05-14
audience: llm-advisory
---

# Browser automation, E2E testing, scraping

### Playbook: Playwright MCP for automated browser tasks

**TL;DR**: Setup completo per usare Playwright via MCP da Claude Code per 3 use case: E2E test generation/fix loop, web scraping (specie JS-rendered), browser automation persistente (login flow, file upload). Pattern raccomandato Anthropic dopo Playwright CLI release. Funziona via accessibility tree (no screenshot/vision), deterministico e veloce.

**Contesti applicabili**: Web | Automation

**Pre-requisiti**:
- Node 20+ per Playwright
- MCP server `@playwright/mcp` o Playwright CLI (Microsoft, raccomandato dal Q4 2025)
- Headless browser installed: `npx playwright install`

**Workflow step-by-step**:

1. **MCP setup** in `.mcp.json`:
   ```json
   {
     "mcpServers": {
       "playwright": {
         "command": "npx",
         "args": ["@playwright/mcp@latest", "--headless"]
       }
     }
   }
   ```
   Oppure preferenza piu recente: `@anthropic-ai/playwright-cli` con stesso comportamento.

2. **Verifica con prompt minimal**: `claude -p "navigate to https://example.com and tell me the H1"` → Playwright si avvia, accessibility tree estratto, risposta in <5s.

3. **Use case A - E2E test generation + fix loop**:
   - User: "scrivi E2E test per checkout flow"
   - Claude: naviga manualmente al flow tramite MCP, registra step
   - Genera test Playwright in `e2e/checkout.spec.ts`
   - Esegue test, se fail debugga riproducendo via MCP

4. **Use case B - Web scraping JS-rendered**:
   - Target: SPA con dati caricati via JS
   - Claude: naviga, attende selector specifico (no sleep, `wait_for_selector`)
   - Estrae via accessibility tree (no screenshot, no OCR)
   - Output JSON strutturato

5. **Use case C - Authenticated session**:
   - Storage state persistente (Playwright `storageState`)
   - Login una volta, riusa cookie/localStorage per N task
   - Useful per: scraping behind login, automation portale legacy

6. **Per scraping massivo - headless mode batch**:
   ```bash
   claude --bare -p "scrape product data from URLs in urls.txt, output JSON" \
     --allowedTools "Bash,Read,Write,mcp__playwright__*" \
     --output-format json
   ```

**Setup files richiesti**:

```json
// .mcp.json - Playwright MCP setup
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {
        "PLAYWRIGHT_HEADLESS": "true",
        "PLAYWRIGHT_STORAGE_STATE": "./.playwright-auth/state.json"
      }
    }
  }
}
```

```yaml
# .claude/skills/e2e-testing/SKILL.md
---
name: e2e-testing
description: |
  Activates when user wants to add or fix E2E tests.
  Uses Playwright MCP to navigate manually, then writes test
  matching what was observed (data-testid > role > text > xpath).
---

Workflow:
1. Use mcp__playwright__navigate, click, fill to walk through the user flow
2. Capture: selectors observed, network calls, expected text/state
3. Generate Playwright test:
   - PREFER data-testid (resilient to UI change)
   - FALLBACK to role-based (`getByRole('button', { name: 'Submit' })`)
   - LAST RESORT xpath/text-match
4. Run test: `pnpm playwright test`
5. If fail: re-navigate manually to debug, NOT just retry with timeout

NEVER: hardcoded sleep(). USE: waitFor, expect.toBeVisible.
NEVER: brittle text-based selectors if data-testid available.
```

```yaml
# .claude/agents/scraper.md
---
name: scraper
description: Headless web scraper. Uses Playwright MCP for JS-rendered sites. Outputs structured JSON.
model: sonnet
tools: mcp__playwright__*, Read, Write, Bash
---

Workflow:
1. Read input (URL list or seed URL)
2. For each URL:
   - Navigate
   - Wait for primary content selector
   - Extract via accessibility tree
   - Map to schema
3. Output JSON to specified path
4. Handle retries with exponential backoff
5. Respect robots.txt (check before scraping)
6. Rate limit: max 1 req/s per domain unless allowed

Anti-patterns:
- screenshot+vision for text extraction (slow, expensive, brittle)
- regex on raw HTML (fragile)
- ignoring 429 responses (gets blocked)
```

**Esempio di sessione tipo (E2E)**:

```
User: scrivi E2E test per il checkout, paga con card test 4242

[e2e-testing skill activates]
Claude: [mcp__playwright__navigate https://staging.app/products]
[mcp__playwright__click product card "Widget Pro"]
[mcp__playwright__click "Add to cart"]
[mcp__playwright__click "Checkout"]
[mcp__playwright__fill #email "test@example.com"]
[mcp__playwright__fill iframe[name=card-element] "4242 4242 4242 4242"]
[mcp__playwright__click "Pay $99"]
[mcp__playwright__wait_for_text "Order confirmed"]
Captured 7 steps + selectors.

[Write e2e/checkout.spec.ts]
```ts
test('checkout with test card', async ({ page }) => {
  await page.goto('/products');
  await page.getByTestId('product-card-widget-pro').click();
  await page.getByRole('button', { name: 'Add to cart' }).click();
  await page.getByRole('link', { name: 'Checkout' }).click();
  await page.getByLabel('Email').fill('test@example.com');
  // Stripe iframe handled via frameLocator
  const stripeFrame = page.frameLocator('iframe[name="card-element"]');
  await stripeFrame.getByLabel('Card number').fill('4242424242424242');
  // ... rest
  await page.getByRole('button', { name: /Pay/ }).click();
  await expect(page.getByText('Order confirmed')).toBeVisible({ timeout: 10_000 });
});
```

[Bash: pnpm playwright test checkout]
PASS in 4.2s.
```

**Esempio sessione tipo (scraping)**:

```
User: scraping prezzo + stock di 200 prodotti su this competitor SPA
      (URL list in urls.txt). Output prodotti.json

[scraper subagent dispatch]
[Bash: cat urls.txt | wc -l → 200]
[robots.txt check: scraping allowed]

[loop 200 URL, rate limit 1/s]
[mcp__playwright__navigate URL]
[mcp__playwright__wait_for_selector "[data-product-info]"]
[accessibility tree extract: price, stock, sku]
[append to prodotti.json]

[errors handling]
3 URL hanno timeout → retry con backoff 2s, 4s
2 URL ritornano 404 → log e skip

[Final: 195/200 success, 5 skip, 0 block]
[Write prodotti.json]
Done in ~3.5min.
```

**Metriche di successo**:
- E2E test stable: <2% flake rate
- Scraping throughput: 1-2 req/s sostenibile (con rate limit)
- Auth state riutilizzabile: 1 login → N session scraping
- Test debugging: time-to-fix flaky test <15min

**Pitfalls comuni**:
- **Selettori fragili** (`.css-xy3z2`): Tailwind/CSS-in-JS hash cambia ogni build. Forza `data-testid` o role-based.
- **`page.waitForTimeout(5000)`**: hardcoded sleep, flaky. Sempre `waitFor`/`expect.toBeVisible`.
- **Screenshot+vision per estrarre testo**: 10x piu lento, costoso (vision model), brittle. Usa accessibility tree.
- **Scraping senza rate limit**: ban immediato. Forza max 1-2 req/s e respect robots.txt.
- **No retry su 429**: scraping fail dopo prima rate limit. Implementa exponential backoff.
- **MCP non installato all'avvio**: agent fallisce su prima navigate. Verifica `npx playwright install` in setup.
- **storageState non aggiornato**: sessione expired = scraping fallisce silent. Refresh login mensile.

**Varianti**:
- **E2E in CI**: usa headless + container, no MCP. Genera test via Claude in dev, run in CI con `playwright test`.
- **Scraping massivo (1000+ URL)**: usa headless Claude (`claude -p --bare`) + batch parallelo con limit semaphore.
- **Browser persistente long-running**: deploy agent come container con `storageState` mounted volume.

**Fonti / Reference reali**:
- [Playwright Plugin Anthropic](https://claude.com/plugins/playwright) - plugin ufficiale
- [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) - MCP server Microsoft
- [MindStudio - Automate Browser Tasks with Claude Code and Playwright MCP](https://www.mindstudio.ai/blog/automate-browser-tasks-claude-code-playwright)
- [Builder.io - Playwright MCP Server with Claude Code](https://www.builder.io/blog/playwright-mcp-server-claude-code)
- [Testomat.io - Playwright MCP + Claude Code AI Test Automation](https://testomat.io/blog/playwright-mcp-claude-code/)
- [Vinicius Dallacqua - Agents That Build Agents (autonomous Notion)](https://dev.to/viniciusdallacqua/agents-that-build-agents-building-autonomous-browsing-with-claude-code-pn5)
- [Anthropic - Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - browser verification pattern
