// Every string the manual shows in pt-BR. Same shape as MANUAL_EN_US; template
// headings, verdicts and statuses stay in en-US, as the skills write them.
// Inline marks: `code`, **bold**, *italic* and [text](#anchor).

const MANUAL_PT_BR = {
  lang: 'pt-BR',

  meta: {
    title: 'PIV Loop — Manual das skills',
    description: 'Plan → Implement → Verify. Dez skills que levam uma ideia da página em branco até um pull request que uma pessoa pode aprovar.',
  },

  ui: {
    brand: 'Manual do PIV Loop',
    skipLink: 'Ir para o conteúdo',
    navLabel: 'Navegação da página',
    menuOpen: 'Sumário',
    menuClose: 'Fechar',
    languageLabel: 'Idioma',
    languages: { 'en-US': 'English', 'pt-BR': 'Português (BR)' },
    copy: 'Copiar',
    copied: 'Copiado',
    copyFailed: 'Falha ao copiar',
  },

  nav: [
    { label: 'O que é o PIV loop', href: '#overview' },
    { label: 'A cadeia num relance', href: '#chain' },
    { label: 'Por onde começo?', href: '#picking' },
    { group: 'Setup' },
    { label: 'piv-setup', href: '#piv-setup', skill: true },
    { group: 'Plan' },
    { label: 'piv-spec', href: '#piv-spec', skill: true },
    { label: 'piv-review-spec', href: '#piv-review-spec', skill: true },
    { label: 'piv-slice', href: '#piv-slice', skill: true },
    { label: 'piv-write-prd', href: '#piv-write-prd', skill: true },
    { group: 'Implement' },
    { label: 'piv-implement', href: '#piv-implement', skill: true },
    { group: 'Verify' },
    { label: 'piv-review', href: '#piv-review', skill: true },
    { label: 'piv-fix', href: '#piv-fix', skill: true },
    { label: 'piv-commit', href: '#piv-commit', skill: true },
    { label: 'piv-open-pr', href: '#piv-open-pr', skill: true },
    { label: 'piv-review-pr', href: '#piv-review-pr', skill: true },
    { group: 'Referência' },
    { label: 'Artefatos e onde ficam', href: '#artifacts' },
    { label: 'Regras da casa', href: '#house-rules' },
    { label: 'Um passo a passo completo', href: '#walkthrough' },
    { label: 'Quais execuções dividem uma sessão', href: '#sessions' },
    { label: 'Solução de problemas', href: '#faq' },
  ],

  hero: {
    eyebrow: 'Manual das skills',
    title: 'The PIV Loop',
    lede: 'Plan → Implement → Verify. Dez skills que levam uma ideia da página em branco até um pull request que uma pessoa pode aprovar — um passo deliberado de cada vez, na sua máquina, com o GitHub como único remote.',
  },

  sections: [
    {
      id: 'overview',
      title: 'O que é o PIV loop',
      blocks: [
        { type: 'p', text: '**PIV** significa **plan → implement → verify**. É o formato pelo qual as skills deste projeto conduzem o trabalho.' },
        {
          type: 'list',
          items: [
            '**Plan** transforma uma ideia numa spec, audita a spec contra o seu código e as suas issues e PRs do GitHub, corta-a em um ticket por task e a publica como uma única issue do GitHub.',
            '**Implement** constrói uma task de cada vez na branch do intent e escreve um relatório de implementação.',
            '**Verify** tenta provar que cada task está errada antes do commit: uma review escreve findings, uma execução de triagem resolve cada um, e só então a task é commitada. Quando todas as tasks entram, o PR é aberto e auditado contra a spec antes que uma pessoa faça o merge.',
          ],
        },
        { type: 'p', text: 'Duas propriedades sustentam tudo. **Cada passo lê o artefato que o passo anterior escreveu** — os relatórios não são burocracia, são a entrada. E **cada passo é iniciado por você**, nunca pelo passo anterior.' },
        {
          type: 'callout',
          title: 'A ideia central',
          text: 'Nada se encadeia sozinho. Cada skill termina dizendo qual é o próximo passo; você decide se o executa. É isso que impede um plano ruim de virar um PR com merge enquanto você estava fora.',
        },
      ],
    },

    {
      id: 'chain',
      title: 'A cadeia num relance',
      blocks: [
        {
          type: 'chain',
          phases: [
            { phase: 'plan', label: 'Plan', skills: ['piv-spec', 'piv-review-spec', 'piv-slice'] },
            {
              phase: 'implement',
              label: 'Implement',
              skills: ['piv-implement'],
              note: '**Uma task de cada vez.** Implement, review, fix e commit se repetem para cada task do epic, na ordem dele.',
            },
            {
              phase: 'verify',
              label: 'Verify',
              skills: ['piv-review', 'piv-fix', 'piv-commit', 'piv-open-pr', 'piv-review-pr'],
              note: '**Cada task fecha com um PASS.** `piv-fix` sempre devolve para um `piv-review` novo. Só um veredito PASS dá direito a commit; o PR é aberto quando todas as tasks estão commitadas.',
            },
          ],
        },
        { type: 'p', text: 'Leia as setas como *"este é o próximo passo oferecido"*, não como automação. A review, a triagem e o commit são o portão de cada task; o PR é a entrega para fora do loop, para uma pessoa que revisa, aprova e faz o merge.' },
      ],
    },

    {
      id: 'picking',
      title: 'Por onde começo?',
      blocks: [
        { type: 'p', text: 'Você raramente precisa das dez. Encontre a linha que corresponde ao que você tem em mãos.' },
        {
          type: 'table',
          head: ['O que você tem', 'Comece com', 'Por quê'],
          rows: [
            ['As skills instaladas com o [comando de instalação](#setup), ainda sem `docs/` para elas', '`piv-setup`', 'Cada passo lê o loop e as git conventions de `docs/`, e guarda seus arquivos num `.piv/` ignorado; sem eles a primeira execução não tem de onde partir.'],
            ['Uma ideia de produto, nada escrito', '`piv-write-prd`', 'Opcional: fixe o *quê e por quê* antes da spec.'],
            ['Um PRD, ou uma ideia clara da mudança', '`piv-spec`', 'Uma entrevista fixa requisitos, design, tasks e verificação numa spec; um PRD é uma entrada como qualquer outra.'],
            ['Uma spec marcada como ready', '`piv-review-spec`', 'Ela confere a spec contra o seu código e as suas issues e PRs do GitHub antes de qualquer coisa ser publicada.'],
            ['Uma spec marcada como reviewed', '`piv-slice`', 'Um ticket por task, cada um uma fatia literal da spec, e uma issue que a publica.'],
            ['Um número de issue', '`piv-implement`', 'Ela escolhe a próxima task do epic e a constrói na branch do intent.'],
            ['Uma task construída, ainda sem commit', '`piv-review`', 'Este é o portão que decide se a task merece um commit.'],
            ['Um relatório de review com findings', '`piv-fix`', 'Findings são entrada, não ordem de serviço — você decide sobre cada um.'],
            ['Um veredito PASS', '`piv-commit`', 'Commits atômicos para a task, depois a próxima task — ou o PR.'],
            ['Todas as tasks commitadas', '`piv-open-pr`', 'Um PR para o intent inteiro, que fecha a issue no merge.'],
            ['Um PR aberto', '`piv-review-pr`', 'Ela confronta o PR com cada item da spec.'],
          ],
        },
      ],
    },

    {
      id: 'setup',
      phase: 'setup',
      title: 'Setup',
      blocks: [
        { type: 'p', text: 'O setup não é um passo do loop: roda uma vez por projeto, antes do primeiro passo, e de novo sempre que chega uma versão mais nova das skills.' },
        { type: 'p', text: 'Instale as skills a partir da raiz do seu projeto com um comando. Ele precisa de Node.js e git, no Windows com Git Bash, macOS ou Linux, e instala apenas para o Claude Code. Depois rode `/piv-setup`.' },
        { type: 'code', text: 'npx skills@1.7.2 add fabianosobreira/piv-pipeline#releases -s \'*\' -a claude-code --copy -y' },
        {
          type: 'list',
          items: [
            '**Faça commit do lock file junto com as skills.** O comando escreve `skills-lock.json` na raiz do projeto; faça commit dele junto com `.claude/skills/`.',
            '**Mantenha seus próprios arquivos fora das pastas `piv-*`.** Cada pasta `.claude/skills/piv-*/` é substituída inteira a cada execução, então um arquivo que você colocar ali é apagado.',
            '**Uma instalação que falhou se recupera rodando o comando de novo.**',
            '**Para atualizar, rode o mesmo comando de novo.** Ele não fixa versão: instala o estado atual da branch `releases`, e o lock file registra só o hash instalado. Para fixar uma versão manualmente, troque `#releases` por `#vX.Y.Z`.',
          ],
        },
        {
          type: 'skill',
          id: 'piv-setup',
          kicker: 'Setup · uma vez por projeto',
          summary: 'Confere que o projeto está no GitHub com o `gh` logado, instala no `docs/` do projeto os docs que cada passo lê, incorpora em `docs/git-conventions.md` as regras de git que o projeto já tem — as suas regras prevalecem sobre os defaults distribuídos — e faz o git ignorar `.piv/`.',
          fields: [
            { label: 'Entrada', text: 'Nenhuma.' },
            { label: 'Saída', text: '`docs/piv-loop.md`; `docs/git-conventions.md`; e a linha `.piv/` no `.gitignore` da raiz, criado quando não existe. Depois um commit, se você aprovar.' },
            { label: 'Como funciona', text: 'Confere o remote e o `gh`, investiga os docs existentes e o harness → rascunha `docs/git-conventions.md` → apresenta o plano inteiro num único portão → instala → mostra a mensagem de commit e espera por você.' },
            {
              label: 'Salvaguardas',
              items: [
                '**GitHub ou nada** — um `origin` fora de `github.com`, ou o `gh` sem login, interrompe a execução com o comando que resolve.',
                '**O harness prevalece** — regras de git do `CLAUDE.md`, do `AGENTS.md`, de arquivos de regras e de ferramentas de commit sobrescrevem o `git-conventions.md` distribuído; cada uma guarda uma nota de onde veio.',
                '**As necessidades das skills são conferidas** — uma base branch, uma forma de subject de commit, uma forma de título de PR e as tags de commit são obrigatórias; uma regra que quebra alguma delas volta para você. Um nome de branch ou subject sem o número da issue é permitido, ao custo de as skills pedirem a issue a cada execução.',
                '**Nada é sobrescrito em silêncio** — um `.gitignore` existente só ganha a linha `.piv/`.',
              ],
            },
            { label: 'Próximo passo', text: 'Nenhum no loop: termina no commit. Escolha seu ponto de partida em [Por onde começo?](#picking)' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use quando**',
              items: [
                'Você acabou de instalar as skills num repo com o comando acima.',
                'Suas regras de git estão no `CLAUDE.md` ou no `AGENTS.md` — ela pode movê-las para `docs/git-conventions.md` e deixar um ponteiro no lugar, se você autorizar.',
                'Chegou uma versão mais nova das skills e os docs devem acompanhar.',
              ],
            },
          ],
        },
      ],
    },

    {
      id: 'plan',
      phase: 'plan',
      title: 'Plan',
      blocks: [
        { type: 'p', text: 'O passo de plan produz a **spec**, que fixa requisitos, design, tasks e verificação num único arquivo; a **review** dela, que a confere contra o que já existe; e os **tickets**, cada um uma fatia literal da spec para uma task, acompanhados por um **epic** local e publicados como uma única **issue** do GitHub. São skills separadas porque respondem a perguntas diferentes. `piv-write-prd` fica à parte: o PRD dela é uma entrada comum da `piv-spec`, passada pelo path.' },
        {
          type: 'skill',
          id: 'piv-spec',
          kicker: 'Plan · passo 1',
          summary: 'Entrevista você em fases fixas e depois escreve uma spec de 10 seções. Cada afirmação vem de uma resposta sua; o agente nunca preenche lacunas.',
          fields: [
            { label: 'Entrada', text: '`[intent-slug]` e o conceito — um parágrafo, um arquivo ou um documento completo com links. URLs que você passa são lidas sem perguntar; links que ela encontra por conta própria são perguntados antes. Um PRD é um desses documentos: passe o path dele, `.piv/[intent-slug]/prd.md`, e a pasta é reaproveitada. Em branco, começa com perguntas.' },
            { label: 'Saída', text: '`.piv/[intent-slug]/spec.md` — objetivo, non-goals, requisitos funcionais (`FR`), requisitos não funcionais (`NFR`), critérios de aceitação (`AC`), restrições (`C`), design (`D`), plano de tasks (`T`), comandos de verificação, limites e um registro de decisões. `Intent-slug` e `Language` ficam no header.' },
            { label: 'Como funciona', text: 'Oito fases de perguntas numeradas; cada afirmação remete a uma resposta sua. Um validador embutido confere estrutura e rastreabilidade: cada `NFR`, `C` e `D` precisa ser citado por uma task, e cada referência precisa resolver. `Status: ready` quando o lint está limpo.' },
            { label: 'Próximo passo', text: '`piv-review-spec [intent-slug]`, numa sessão própria.' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use quando**',
              items: [
                'Você tem uma mudança em mente, com ou sem PRD, e quer fixá-la antes que alguém construa.',
                'Um agente de IA vai implementá-la e precisa de requisitos que consiga verificar.',
              ],
            },
            { type: 'p', text: '**Pule quando** a mudança é uma correção de uma linha que você faz à mão.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-review-spec',
          kicker: 'Plan · passo 2',
          summary: 'Audita uma spec ready antes da publicação: o que o codebase já contém, o que as issues e PRs do repo já dizem, e cada item que a entrevista deixou adiado. Resolve cada um com você e marca a revisão da spec como reviewed.',
          fields: [
            { label: 'Entrada', text: '`[intent-slug]`, para uma spec com `Status: ready`. Um `draft` interrompe a execução.' },
            { label: 'Saída', text: 'A spec, editada só com as suas respostas, em `Status: reviewed`; e `.piv/[intent-slug]/spec.review.md` — o que existe no código, as issues e PRs conflitantes, o que você resolveu, o que mudou, e o `Reviewed-hash` da spec. Um problema que exige nova entrevista reabre a spec como `draft`.' },
            { label: 'Como funciona', text: 'Lê a spec → busca no codebase → busca nas issues e PRs do repo com o `gh`, só leitura → pergunta, no mesmo formato numerado da `piv-spec` → aplica as respostas e roda o lint → marca o resultado. Sem o `gh` logado ela para, a menos que você decida seguir sem a checagem remota.' },
            { label: 'Próximo passo', text: '`piv-slice [intent-slug]`, numa sessão própria.' },
          ],
          notes: [
            { type: 'p', text: '**Por que uma execução separada.** A entrevista que escreveu a spec é a pior juíza dela. Uma sessão nova encontra o código que já faz metade do trabalho, e a issue fechada que já rejeitou a ideia, antes que a spec vire uma issue pública.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-slice',
          kicker: 'Plan · passo 3',
          summary: 'Corta uma spec reviewed em um ticket por task e um epic que os acompanha, depois publica a spec como a única issue do GitHub do intent. Cada ticket copia, linha por linha, a parte da spec de que sua task precisa — nada é criado nem reescrito.',
          fields: [
            { label: 'Entrada', text: '`[intent-slug]`, para uma spec em `Status: reviewed` cujo hash bate com o da review. Um `draft`, um `ready` ou uma spec editada depois da review interrompe a execução.' },
            { label: 'Saída', text: '`tasks/T-xx/T-xx.md`, um ticket por task, cada um com um header block (`Spec` com o hash da revisão, `Slice`, `Type`, `Blocked by`, `Size`, `Intent-slug`, `Language`) e as seções da spec; `epic.md`, a lista de tasks a fazer; e uma issue do GitHub, com a spec inteira como corpo, um label de tipo — `bug`, `feature` ou `task` — e você como assignee.' },
            { label: 'Como funciona', text: 'Não interativa durante o corte, o lint e o preflight do `gh`, depois **um portão** onde você aprova a issue: o título, o label e o aviso de que a spec é publicada por inteiro. Um validador embutido, `lint_ticket.sh`, rejeita qualquer linha de ticket que não seja uma linha literal da spec, e qualquer ticket com mais de uma task; nada chega ao GitHub até que todos os tickets passem.' },
            { label: 'Próximo passo', text: '`piv-implement [#N]`, numa sessão própria.' },
          ],
          notes: [
            { type: 'p', text: '**Use quando** uma spec está reviewed e você precisa dela cortada em unidades que um agente consiga terminar e provar, uma de cada vez.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-write-prd',
          kicker: 'Avulsa',
          summary: 'Entrevista você para fixar o problema, por que construir, e uma hipótese falseável — depois escreve um PRD de nível de produto. Só intenção: *o quê* e *por quê*, nunca decisões de engenharia. Não é um passo do loop: o PRD dela é uma entrada comum da `piv-spec`, passada pelo path.',
          fields: [
            { label: 'Entrada', text: '`[product idea]` mais paths opcionais para docs de pesquisa — entrevistas com usuários, temas de tickets de suporte, analytics, análises de concorrentes. Em branco, começa com perguntas.' },
            { label: 'Saída', text: '`.piv/[intent-slug]/prd.md` — declaração do problema, evidências, tese, hipótese, usuário-alvo e JTBD, restrições, MVP, métricas de sucesso, non-goals, perguntas em aberto.' },
            { label: 'Como funciona', text: 'Uma entrevista agrupada em cinco fases, cada uma terminando num portão onde espera por você. As perguntas são numeradas ao longo de toda a execução, e a hipótese volta para você montada com as suas próprias palavras antes de ser final.' },
            {
              label: 'Salvaguardas',
              items: [
                '**Evidência ou TBD** — cada requisito remete a algo que você disse ou que um doc mostrou; o que é desconhecido é escrito como "TBD — needs validation".',
                '**Enquadrado na intenção, sem prescrever solução** — se só uma solução cabe na declaração do problema, é uma spec, não um PRD.',
              ],
            },
            { label: 'Próximo passo', text: '`piv-spec .piv/[intent-slug]/prd.md`, numa sessão própria.' },
          ],
          notes: [
            {
              type: 'list',
              lead: '**Use quando**',
              items: [
                'Você está começando algo greenfield e ninguém escreveu o problema ainda.',
                'Duas pessoas do time descreveriam "o problema" de jeitos diferentes.',
              ],
            },
            { type: 'p', text: '**Pule quando** a mudança já está clara o bastante para ir direto à `piv-spec`.' },
          ],
        },
      ],
    },

    {
      id: 'implement',
      phase: 'implement',
      title: 'Implement',
      blocks: [
        {
          type: 'skill',
          id: 'piv-implement',
          kicker: 'Implement · por task',
          summary: 'Constrói uma task a partir do seu ticket na branch do intent, validando a cada passo, e escreve um relatório de implementação. O trabalho fica sem commit para a review.',
          fields: [
            { label: 'Entrada', text: '`[#N | intent-slug] [T-xx]`. Em branco, pega a issue do nome da branch e a próxima task do epic: a que está em andamento, senão a primeira cujas dependências estão todas commitadas.' },
            { label: 'Saída', text: '`tasks/T-xx/T-xx.report.md` — resumo, tasks concluídas, testes adicionados, resultados da validação, **deviations from the ticket**, problemas encontrados. O status é `COMPLETE` ou `PARTIAL` — `PARTIAL` também quando um arquivo alterado é ignorado pelo git, já que ele nunca viaja com a branch. A task vira `[~]` no epic.' },
            { label: 'Como funciona', text: 'Resolve a task e confere as dependências → trabalha na branch do intent, criada pela primeira task como `[tag]/[N]-[intent-slug]` → lê o ticket de ponta a ponta e confere se houve drift → executa as tasks em ordem → fecha a estratégia de testes → roda as checagens → verificação final.' },
            { label: 'Próximo passo', text: '`piv-review [#N] [T-xx]`, numa sessão própria.' },
          ],
          notes: [
            { type: 'p', text: '**Por que os desvios importam.** O reviewer lê este relatório. Um desvio registrado aqui é uma decisão *intencional* que o reviewer não deve apontar; o mesmo desvio não registrado volta como finding. A exceção é um teste: um teste pulado, afrouxado, reescrito ou apagado continua bloqueando a review, mesmo quando um desvio o explica.' },
          ],
        },
      ],
    },

    {
      id: 'verify',
      phase: 'verify',
      title: 'Verify',
      blocks: [
        { type: 'p', text: 'Verify são cinco skills e uma regra: **review e correções são execuções separadas**. O reviewer escreve findings e não toca no código. A execução de triagem decide o que acontece com cada finding, com você decidindo a divisão. Review, triagem e commit rodam por task; o PR e a auditoria dele rodam uma vez, para o intent inteiro.' },
        {
          type: 'skill',
          id: 'piv-review',
          kicker: 'Verify · o portão, por task',
          summary: 'Revisa a mudança sem commit de uma task em busca de bugs, defeitos de segurança e violações de padrões, e escreve um relatório de review. É um relatório, nunca uma edição.',
          fields: [
            { label: 'Entrada', text: '`[#N | intent-slug] [T-xx]` — em branco, pega a issue do nome da branch e a task em andamento do epic.' },
            { label: 'Saída', text: '`tasks/T-xx/T-xx.review.md` — escopo (cada arquivo lido), findings agrupados em `blocking` / `critical` / `high` / `medium` / `low`, e as checagens executadas, entre elas a suíte de testes completa. Um finding `blocking` é um teste vermelho, ausente ou enfraquecido, ou um comportamento sem teste — um fato, fora da escala de severidade. Cada finding traz evidência, impacto e uma correção concreta.' },
            { label: 'Veredito', text: '**CHANGES REQUESTED** quando sobrevive qualquer finding blocking, critical ou high. **PASS** caso contrário — um PASS com findings medium e low é normal.' },
            { label: 'Como funciona', text: 'Resolve a mudança contra o `HEAD`, o último commit antes da task → resolve os deferrals anteriores → lê os padrões que a mudança precisa cumprir → examina cada arquivo alterado no seu contexto → monta o caso → roda três filtros que eliminam findings não comprovados. A mudança é confrontada com os critérios de aceitação do ticket além da estratégia de testes: um critério que o código não cumpre é um finding `high`.' },
            { label: 'Próximo passo', text: '**PASS** sem findings → `piv-commit [#N] [T-xx]`, aqui ou numa sessão nova. **PASS** com findings medium ou low → `piv-commit [#N] [T-xx]`, numa sessão própria. **CHANGES REQUESTED** → `piv-fix`, numa sessão própria, recebendo o path deste relatório.' },
          ],
          notes: [
            { type: 'p', text: '**Use** antes de commitar uma task, e de novo depois de cada execução de fix. Numa nova review ela sobrescreve o relatório anterior: ele é o estado atual da task, e as decisões sobre findings antigos ficam nos deferrals, não aqui.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-fix',
          kicker: 'Verify · triagem',
          summary: 'Faz a triagem dos findings da review, corrige os que você escolher um de cada vez com testes, adia o resto como deferrals locais, valida e escreve um relatório de correções.',
          fields: [
            { label: 'Entrada', text: '`[review report path]` — em branco, usa a review da task em andamento.' },
            { label: 'Saída', text: '`tasks/T-xx/T-xx.fixes.md` — **Fixed**, **Deferred** (com seus `D-xx`), **Needs a human look**, **Noise / won\'t-fix**, e as checagens executadas. Cada deferral vai para `deferrals/D-xx.md` e para a lista do epic; nenhuma issue é criada.' },
            { label: 'Como funciona', text: 'Classifica cada finding num dos quatro grupos — um finding blocking só em *fix now* ou *noise*, nunca adiado → corrige o conjunto *fix now* um de cada vez, cada um com um teste que o prova → valida a branch inteira.' },
            { label: 'Próximo passo', text: '`piv-review [#N] [T-xx]` de novo, numa sessão própria. Com uma entrada *Needs a human look* ainda aberta, a passagem espera: inspecione-a e rode `piv-fix` de novo.' },
          ],
          notes: [
            { type: 'p', text: '**Por que o relatório existe.** A triagem é uma decisão humana, e uma decisão que vive só na conversa some até a próxima execução. O relatório de correções e os arquivos de deferral são o que dizem à nova review que um finding já foi resolvido — assim, findings resolvidos continuam resolvidos.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-commit',
          kicker: 'Verify · commit, por task',
          summary: 'Commita uma task revisada como commits atômicos com tags convencionais — cada um uma unidade coerente de trabalho que a linha de subject consegue nomear — e marca a task como concluída no epic.',
          fields: [
            { label: 'Entrada', text: '`[#N | intent-slug] [T-xx]` — em branco, pega a issue do nome da branch e a task em andamento do epic.' },
            { label: 'Saída', text: 'Commits na branch do intent, cada subject terminando em `(#N)`, mais um resumo "What Changed". A task vira `[x]` no epic, com os short hashes dos seus commits. A execução termina com a árvore limpa.' },
            { label: 'Como funciona', text: 'Confere onde você está e se a árvore ainda corresponde ao PASS → inspeciona a árvore → agrupa as mudanças → commita cada grupo → marca a task como concluída.' },
            { label: 'Próximo passo', text: 'Uma task ainda aberta → `piv-implement [#N]`, numa sessão própria. Todas as tasks concluídas → `piv-open-pr [#N]`, nesta mesma sessão.' },
          ],
          notes: [
            { type: 'p', text: '**Use** quando o veredito da review da task for PASS. Normalmente é um único commit; quando a árvore contém trabalho não relacionado ela divide, e qualquer coisa que não cabe em nenhum grupo interrompe a execução e pergunta a você.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-open-pr',
          kicker: 'Verify · entrega',
          summary: 'Abre o pull request do GitHub para um intent cujas tasks estão todas commitadas, fechando a issue no merge, e entrega a URL a uma pessoa revisora.',
          fields: [
            { label: 'Entrada', text: '`[#N | intent-slug] · [base branch]` — em branco, pega a issue do nome da branch e usa a base branch do projeto.' },
            { label: 'Saída', text: 'Uma branch publicada e um PR aberto, com o label da issue e você como assignee. O corpo traz `Closes #N`, a revisão da spec e, por task, o resumo, a validação, os desvios, os findings que sobreviveram e os problemas em aberto — mais cada deferral por inteiro. Informa o número do PR, a URL e as branches base ← head.' },
            { label: 'Como funciona', text: 'Resolve o intent e a base branch → confere que cada task está concluída e cada commit está na branch → monta o corpo a partir dos relatórios e dos deferrals → publica → abre o PR com o `gh`.' },
            { label: 'Próximo passo', text: '`piv-review-pr [#N]`, numa sessão própria — depois uma pessoa revisa, aprova e faz o merge.' },
          ],
          notes: [
            { type: 'p', text: '**A issue se fecha sozinha.** `Closes #N` no corpo fecha a issue quando o PR recebe merge; nenhum passo a fecha à mão.' },
          ],
        },
        {
          type: 'skill',
          id: 'piv-review-pr',
          kicker: 'Verify · auditoria',
          summary: 'Audita o PR aberto contra a spec, item por item, e escreve uma review de PR com veredito **CONFORMS** ou **DIVERGES**. Julga conformidade, não qualidade de código — a `piv-review` já fez isso, task por task.',
          fields: [
            { label: 'Entrada', text: '`[#N | intent-slug]` — em branco, pega a issue do nome da branch.' },
            { label: 'Saída', text: '`.piv/[intent-slug]/pr-review.md` — cada `FR`, `NFR`, `C`, `D` e `AC` marcado como *met*, *diverges* ou *not verifiable* com sua evidência; as divergências, incluindo mudanças fora do escopo, com uma severidade; os non-goals e as linhas *Never*, respeitados ou violados; e se a spec mudou depois que o PR foi aberto.' },
            { label: 'Como funciona', text: 'Lê o PR com o `gh`, só leitura → indexa a spec → lê o diff inteiro → confronta cada item com ele → compara as revisões da spec → escreve a review. Nunca comenta no PR.' },
            { label: 'Próximo passo', text: '**CONFORMS** → uma pessoa faz o merge. **DIVERGES** → você decide: corrigir à mão, planejar como um novo intent, ou aceitar. **O loop do agente termina no merge.**' },
          ],
        },
      ],
    },

    {
      id: 'artifacts',
      title: 'Artefatos e onde ficam',
      blocks: [
        { type: 'p', text: 'Cada passo lê o artefato anterior, então os paths importam. Eles são definidos em `docs/piv-loop.md`, que a [`piv-setup`](#piv-setup) instala junto com um `docs/git-conventions.md` mesclado com as regras de git que o seu `CLAUDE.md`, `AGENTS.md` ou ferramenta de commit já definem. Tudo abaixo fica em `.piv/[intent-slug]/` na raiz do repo, que o git ignora.' },
        {
          type: 'table',
          head: ['Artefato', 'Path', 'Escrito por', 'Lido por'],
          rows: [
            ['PRD', '`prd.md`', '`piv-write-prd`', 'spec'],
            ['Spec', '`spec.md`', '`piv-spec`', 'spec review, slice, PR review'],
            ['Spec review', '`spec.review.md`', '`piv-review-spec`', 'slice'],
            ['Epic', '`epic.md`', '`piv-slice`, depois cada passo que marca uma task', 'cada passo a partir do implement'],
            ['Tickets', '`tasks/T-xx/T-xx.md`', '`piv-slice`', 'implement, review, fix'],
            ['Relatório de implementação', '`tasks/T-xx/T-xx.report.md`', '`piv-implement`', 'review, PR'],
            ['Relatório de review', '`tasks/T-xx/T-xx.review.md`', '`piv-review`', 'fix, nova review, commit, PR'],
            ['Relatório de correções', '`tasks/T-xx/T-xx.fixes.md`', '`piv-fix`', 'nova review, PR'],
            ['Deferrals', '`deferrals/D-xx.md`', '`piv-fix`', 'nova review, PR'],
            ['PR review', '`pr-review.md`', '`piv-review-pr`', 'você'],
          ],
        },
        { type: 'p', text: 'O GitHub guarda só duas coisas: a issue, criada pela `piv-slice` com a spec como corpo, e o PR, aberto pela `piv-open-pr`. Todo outro artefato fica na sua máquina.' },
        {
          type: 'callout',
          title: 'Por que local primeiro',
          text: 'Um plano é barato de mudar enquanto é um arquivo e caro quando vira um tracker cheio de tickets, comentários e links. Manter a spec, os tickets e cada relatório locais deixa o loop reescrevê-los livremente, e deixa no GitHub o que as pessoas de fato leem: uma issue que declara o intent, e um PR que o entrega.',
        },
        {
          type: 'callout',
          title: 'Por que uma issue, uma branch, um PR',
          text: 'O número da issue é a identidade do intent no git: a branch é `[tag]/[N]-[intent-slug]`, cada commit termina em `(#N)`, e o PR fecha `#N`. Uma task é um commit nessa branch, então o histórico se lê task por task, e uma pessoa revisa o intent inteiro uma vez em vez de uma pilha de PRs pequenos.',
        },
        {
          type: 'callout',
          title: 'O intent-slug',
          text: 'Cada artefato de um intent carrega o mesmo `intent-slug`: o kebab-slug do título do produto, ou do objetivo da spec, em ASCII minúsculo sem acentos. Ele nomeia a pasta do intent em `.piv/`, e cada artefato abre com um **header block** — uma lista markdown curta, um campo em negrito por linha — que o carrega. Os passos seguintes **o leem do artefato em vez de derivá-lo de novo** — assim um PRD escrito em `user-auth/` nunca ganha uma spec `authentication/` ao lado.',
        },
      ],
    },

    {
      id: 'house-rules',
      title: 'Regras da casa',
      blocks: [
        {
          type: 'list',
          ordered: true,
          items: [
            '**Nada se encadeia sozinho.** Cada skill termina oferecendo o próximo passo; você o executa.',
            '**Cada passo lê o artefato anterior.** Os relatórios são a entrada da próxima execução, não burocracia.',
            '**As skills param em vez de adivinhar.** Uma spec não revisada, uma task cuja dependência não foi commitada, uma árvore suja com trabalho que não cabe em nenhum grupo, o `gh` sem login — a execução para e pergunta.',
            '**O GitHub é escrito duas vezes.** A `piv-slice` cria a issue e a `piv-open-pr` abre o PR; todo outro passo só lê, ou fica local.',
            '**Review e correções são execuções separadas.** O reviewer escreve findings e não toca no código; a execução de triagem decide o que acontece com cada um, com você decidindo a divisão.',
            '**Cada task fecha com um PASS.** Uma execução de fix sempre devolve para uma review nova, que lê os deferrals para que findings resolvidos continuem resolvidos.',
            '**Uma task de cada vez.** As tasks rodam na ordem do epic, nunca em paralelo, cada uma commitada antes de a próxima começar.',
            '**Um idioma por intent.** O PRD — ou, sem PRD, a spec — é escrito no idioma em que você dá a entrevista, e todo artefato seguinte o acompanha. Títulos e labels dos templates ficam como os templates os escrevem.',
          ],
        },
        {
          type: 'callout',
          title: 'Se uma execução parar e perguntar algo',
          text: 'É o design, não uma falha. Responda e rode de novo — adivinhar é a única coisa que essas skills não vão fazer por você.',
        },
      ],
    },

    {
      id: 'walkthrough',
      title: 'Um passo a passo completo',
      blocks: [
        { type: 'p', text: 'Um intent com duas tasks, do início ao merge. Cada linha é algo que você digita, e os passos estão agrupados pela sessão em que rodam; a nota ao lado de cada grupo diz por quê, e [quais execuções dividem uma sessão](#sessions) explica o raciocínio.' },
        {
          type: 'walkthrough',
          groups: [
            {
              steps: [{ n: 1, cmd: 'piv-write-prd', text: 'entrevista, depois um PRD chega em `.piv/team-inbox/prd.md`.' }],
              note: '**Sessão própria.** O PRD é escrito num arquivo, e o próximo passo o lê de lá; nada precisa ficar na conversa.',
            },
            {
              steps: [{ n: 2, cmd: 'piv-spec .piv/team-inbox/prd.md', text: 'recebe o PRD como entrada; a entrevista, depois uma spec chega em `.piv/team-inbox/spec.md`.' }],
              note: '**Sessão nova.** O PRD já contém o intent; a entrevista da spec parte do arquivo, não do contexto da entrevista do PRD.',
            },
            {
              steps: [{ n: 3, cmd: 'piv-review-spec team-inbox', text: 'encontra um PR aberto que se sobrepõe a um requisito; você resolve, e a spec fica reviewed.' }],
              note: '**Sessão nova.** A review não pode dividir o contexto da entrevista.',
            },
            {
              steps: [{ n: 4, cmd: 'piv-slice team-inbox', text: 'dois tickets e o epic; você aprova a issue no portão, e a issue `#123` é aberta com a spec como corpo.' }],
              note: '**Sessão nova.** O slice só roda sobre o que a review aprovou, e a spec e a review dela já contêm tudo de que ele precisa.',
            },
            {
              steps: [{ n: 5, cmd: 'piv-implement #123', text: 'branch `feat/123-team-inbox`, task `T-01`, seus testes, e `tasks/T-01/T-01.report.md`.' }],
              note: '**Sessão nova, uma por task.** O passo mais pesado precisa da janela inteira; na sessão de planejamento ele deixaria passar as lacunas do ticket e traria de volta alternativas que as entrevistas rejeitaram.',
            },
            {
              steps: [{ n: 6, cmd: 'piv-review #123', text: 'veredito **CHANGES REQUESTED**, 1 high e 3 medium em `tasks/T-01/T-01.review.md`.' }],
              note: '**Sessão nova, sempre.** Na sessão da implementação a review relê as próprias decisões e tende a confirmá-las.',
            },
            {
              steps: [{ n: 7, cmd: 'piv-fix .piv/team-inbox/tasks/T-01/T-01.review.md', text: 'você corrige o high e um medium, adia dois como `D-01` e `D-02`; `T-01.fixes.md` registra cada decisão.' }],
              note: '**Sessão nova.** A execução que levantou os findings tende a defendê-los; a triagem precisa estar livre para decidir contra a review.',
            },
            {
              steps: [{ n: 8, cmd: 'piv-review #123', text: 'lê os deferrals, e o veredito é **PASS**.' }],
              note: '**Sessão nova, sempre.** Na sessão do fix a review aprovaria a própria correção; só um PASS independente fecha o loop.',
            },
            {
              steps: [{ n: 9, cmd: 'piv-commit #123', text: 'um commit terminando em `(#123)`; `T-01` vira `[x]` no epic.' }],
              note: '**Sessão nova.** O corpo do commit vem do diff, não dos relatórios. Depois os passos 5–9 rodam de novo para `T-02`.',
            },
            {
              steps: [
                { n: 10, cmd: 'piv-commit #123', text: 'a última task é commitada.' },
                { n: 11, cmd: 'piv-open-pr #123', text: 'o PR é aberto com `Closes #123` e os dois deferrals no corpo.' },
              ],
              note: '**Uma sessão para os dois.** Carregar um contexto do tamanho de uma review custa mais do que recomeçar; o PR descreve o que os commits registraram, então nada entre eles precisa ficar independente.',
            },
            {
              steps: [{ n: 12, cmd: 'piv-review-pr #123', text: 'cada item da spec está *met*: **CONFORMS**, e uma pessoa faz o merge.' }],
              note: '**Sessão nova.** A auditoria não pode dividir o contexto da execução que entregou o que ela audita.',
            },
          ],
        },
        { type: 'p', text: 'Os passos 6–8 se repetem quantas vezes a task precisar, cada passagem em sessões novas. Esse ciclo *é* o loop.' },
      ],
    },

    {
      id: 'sessions',
      title: 'Quais execuções dividem uma sessão',
      blocks: [
        { type: 'p', text: 'Cada passagem viaja por um artefato — a spec, o epic, os tickets, os relatórios, os commits, o nome da branch — nunca pela conversa. Uma sessão nova nunca perde nada de que o próximo passo precisa, então a escolha pesa duas coisas: se a próxima execução precisa ser independente, e quanto a sessão custa em tokens.' },
        { type: 'p', text: 'Uma sessão compartilhada economiza a releitura de arquivos, mas cada turno reenvia a sessão inteira, e esse custo cresce a cada tool call. Uma sessão nova paga a releitura uma vez e mantém os turnos seguintes leves. Compartilhar só compensa quando o próximo passo releria quase tudo o que o anterior leu **e** a independência não importa — por isso só o último commit e o PR dividem uma (e um commit com uma review que terminou limpa).' },
        {
          type: 'callout',
          title: 'Combinações a evitar',
          text: '**spec + spec review**: a entrevista julga a si mesma. **implement + review**: autoaprovação. **review + fix**: a triagem não consegue decidir contra os findings. **fix + nova review**: o loop fecha sem um PASS independente. **fix ou nova review + commit**: uma sessão inchada, e um corpo de commit que reconta os relatórios. **planejamento + implement**: as lacunas do ticket passam despercebidas e alternativas rejeitadas voltam. **open PR + PR review**: a auditoria herda a história do que foi entregue.',
        },
      ],
    },

    {
      id: 'faq',
      title: 'Solução de problemas',
      blocks: [
        {
          type: 'faq',
          items: [
            { q: 'A review continua levantando algo que eu já decidi adiar.', a: 'O deferral precisa existir como arquivo em `deferrals/` cujo *Origin* nomeia a task, não só como uma linha na conversa. A `piv-fix` escreve esses arquivos; a `piv-review` os lê no passo 2. Se o arquivo não estiver lá, o finding volta legitimamente. Um finding blocking volta mesmo quando adiado: só fecha corrigindo, ou mostrando que o problema não existe.' },
            { q: 'O reviewer apontou algo que eu mudei de propósito.', a: 'Registre em **Deviations from the ticket** no relatório de implementação. Essa seção é o sinal de intenção para o reviewer. Um teste que você mudou é a exceção: pulado, afrouxado, reescrito ou apagado, ele continua bloqueando a review.' },
            { q: 'Posso pular o PRD?', a: 'Sim. O PRD é uma entrada entre outras para a `piv-spec`, e a spec é o que o resto do loop lê.' },
            { q: 'Posso rodar várias tasks ao mesmo tempo?', a: 'Não. As tasks dividem uma branch e são commitadas na ordem do epic, para que cada review veja exatamente a mudança de uma task contra o último commit.' },
            { q: 'Editei a spec e agora a piv-slice para.', a: 'Esperado. A review aprovou uma revisão da spec, pelo hash; qualquer edição depois disso precisa da `piv-review-spec` de novo.' },
            { q: 'A review do PR diz DIVERGES. A piv-fix resolve?', a: 'Não. A `piv-fix` faz a triagem da review de uma task. Uma divergência no PR é corrigida à mão na branch, planejada como um novo intent, ou aceita no merge — você decide.' },
            { q: 'Nada aconteceu depois que uma skill terminou.', a: 'Esperado. As skills não se encadeiam — leia o próximo passo que ela ofereceu e rode você mesmo.' },
          ],
        },
      ],
    },
  ],
};
