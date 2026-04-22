/**
 * LiveSheet REGEN: Sovereign Engine (v1.1.2)
 * ---------------------------------------------------------
 * 브라우저가 무시하는 <link rel="livesheet">를 강제로 인식하여 
 * 독립 언어 LSL의 생태계를 활성화하는 마스터 엔진입니다.
 */

class LiveSheetREGEN {
    constructor() {
        this.entities = new Map();
        this.dataCache = new Map();
        this.config = null;
        this.init();
    }

    async init() {
        console.log("%c[LSL Core] System Standby. Searching for LSL manifest...", "color: #00ccff;");

        // [핵심] 브라우저가 인식하지 않는 link 태그를 강제로 찾아냄
        const lslLink = document.querySelector('link[rel="livesheet"]');
        
        if (!lslLink) {
            console.error("[LSL Error] 인식 가능한 LSL 설계도가 없습니다. <link rel='livesheet' href='...'>를 확인하세요.");
            return;
        }

        const lslPath = lslLink.getAttribute('href');
        console.log(`[LSL Core] Manifest detected: ${lslPath}`);

        try {
            const rawLSL = await this.fetchSource(lslPath);
            const parsedData = this.parseLSL(rawLSL);
            this.bootstrap(parsedData);
        } catch (err) {
            console.error("[LSL Critical] 엔진 가동 실패:", err);
        }
    }

    // 파일 읽기 (Nekoweb 및 GitHub 대응)
    async fetchSource(url) {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Source 404: ${url}`);
        return await response.text();
    }

    // LSL 언어 파서 (텍스트 -> JSON)
    parseLSL(text) {
        const result = { kernel: {}, chronos: {}, themes: {}, streams: {}, entities: {} };
        const lines = text.split('\n').filter(line => !line.trim().startsWith('--'));
        const cleanText = lines.join('\n');

        const sections = cleanText.split(/@(\w+)\s*#?([\w\d_]+)?\s*{/);
        
        for (let i = 1; i < sections.length; i += 3) {
            const type = sections[i].trim();
            const id = sections[i+1] ? sections[i+1].trim() : 'default';
            const body = sections[i+2].split('}')[0].trim();
            const pairs = body.split(';').filter(p => p.includes(':')).reduce((acc, p) => {
                const [k, v] = p.split(':').map(s => s.trim());
                acc[k] = v.replace(/['"]/g, '');
                return acc;
            }, {});

            if (type === 'kernel' || type === 'system') result.kernel = pairs;
            else if (type === 'chronos' || type === 'global_cycle') result.chronos = pairs;
            else if (type === 'aesthetic' || type === 'theme') result.themes[id] = pairs;
            else if (type === 'inject' || type === 'data_stream') result.streams[id] = pairs;
            else if (type === 'entity' || type === 'object') result.entities[id] = pairs;
        }
        return result;
    }

    bootstrap(data) {
        this.config = data;
        this.createViewport();

        // 각 엔티티에 개별 심장박동(Pulse) 부여
        Object.entries(data.entities).forEach(([id, spec]) => {
            this.spawnEntity(id, spec);
        });
    }

    createViewport() {
        const viewport = document.createElement('div');
        viewport.id = 'lsl-viewport';
        // 4:3 비율 강제 및 중앙 정렬
        Object.assign(viewport.style, {
            position: 'relative',
            width: '800px',
            height: '600px',
            backgroundColor: '#000',
            margin: '20px auto',
            overflow: 'hidden',
            border: '5px solid #333',
            boxSizing: 'content-box'
        });
        document.body.appendChild(viewport);
        this.view = viewport;
    }

    spawnEntity(id, spec) {
        const el = document.createElement('div');
        el.id = `entity-${id}`;
        
        // 기본 스타일 및 테마 적용
        const themeId = spec.apply_theme || spec.apply;
        const theme = this.config.themes[themeId?.replace('#', '')] || {};
        
        Object.assign(el.style, {
            position: 'absolute',
            border: theme.outline || '2px solid white',
            borderRadius: theme.border_radius || '0px',
            backgroundColor: '#222',
            color: '#fff',
            transition: 'transform 0.6s cubic-bezier(0.4, 0, 0.2, 1)',
            padding: '10px',
            overflow: 'hidden'
        });

        // 위치 지정 (Grid/Percent)
        const pos = spec.position?.match(/\d+/g) || [0, 0];
        const size = spec.size?.match(/\d+/g) || [100, 100];
        el.style.left = `${pos[0]}%`;
        el.style.top = `${pos[1]}%`;
        el.style.width = `${size[0]}px`;
        el.style.height = `${size[1]}px`;

        // [핵심] 호버 시 시간 동결 (Pointer Watcher)
        let isHovered = false;
        el.addEventListener('mouseenter', () => { isHovered = true; el.style.zIndex = "100"; });
        el.addEventListener('mouseleave', () => { isHovered = false; el.style.zIndex = "1"; });

        this.view.appendChild(el);

        // [핵심] 30-60초 랜덤 박동 루프
        const pulse = async () => {
            if (!isHovered) {
                const streamId = spec.use_stream || spec.bind;
                const stream = this.config.streams[streamId?.match(/\d+/)?.[0]];
                
                if (stream) {
                    try {
                        const data = await this.fetchSource(stream.source);
                        // Ghost Buffer: 이전 데이터와 비교
                        if (this.dataCache.get(id) !== data) {
                            this.dataCache.set(id, data);
                            this.animateFlip(el, data);
                        }
                    } catch (e) {
                        el.innerHTML = "SIGNAL ERROR";
                    }
                }
            }
            const next = Math.random() * (60000 - 30000) + 30000;
            setTimeout(pulse, next);
        };
        pulse();
    }

    animateFlip(el, data) {
        el.style.transform = "rotateX(90deg)";
        setTimeout(() => {
            el.innerHTML = `<div style="font-family:monospace; font-size:11px;">${data}</div>`;
            el.style.transform = "rotateX(0deg)";
        }, 300);
    }
}

// 즉시 실행
new LiveSheetREGEN();
