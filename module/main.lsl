-- [[ LiveSheet REGEN: Master Module Specification (v1.1.0) ]]
-- Author: dummyowner (Guest-1Play)
-- Identity: Sovereign Independent Language for 4:3 Live-Interfaces

-- ==========================================
-- 1. KERNEL AUTHORITY (커널 및 실행 권한)
-- ==========================================
@kernel {
    viewport: 4:3;
    threading: "independent-pulse"; -- 각 오브젝트가 개별 스레드처럼 작동
    runtime: "no-stop-persistent";  -- 프로세스 종료 전까지 무한 상주
    memory_guard: strict;           -- 고스트 버퍼를 통한 불필요한 렌더링 원천 차단
}

-- ==========================================
-- 2. UNIVERSAL CHRONOS (시간 및 동기화 법칙)
-- ==========================================
@chronos {
    -- 보편적 박동 주기: 30초에서 60초 사이의 랜덤성 부여
    pulse_range: 30s, 60s;
    
    -- 시각 인지 반응: 마우스가 닿으면 해당 개체의 시간 축을 '동결'
    on_pointer: action(freeze_time);
    
    -- 지능형 갱신: 데이터 델타(변화량)가 0이면 사이클을 무시하고 재대기
    update_condition: delta_check > 0;
}

-- ==========================================
-- 3. REGEN AESTHETIC (독자적 시각 문법)
-- ==========================================
@aesthetic #regen_v1 {
    rendering_engine: "messy-canvas"; 
    stroke: 3px solid #000000;      -- 손그림 특유의 거친 블랙 아웃라인
    corner_logic: "organic-chaos";  -- 수작업 느낌의 불규칙한 라운딩
    color_profile: "flat-muted";    -- 00년대 소프트웨어 특유의 저채도 배색
    font: "lsl-tech-dot";           -- LSL 전용 도트 매트릭스 가독성 확보
}

-- ==========================================
-- 4. RESILIENCE (환경 적응 및 복구 시스템)
-- ==========================================
@resilience {
    -- 서버 다운 시 '죽은 화면' 대신 시스템 고유의 페르소나 유지
    on_data_loss: "render_noise_and_wait"; 
    reconnect_strategy: exponential_backoff(120s);
    emergency_buffer: "display_last_cached"; -- 최악의 경우 마지막 데이터를 유지
}

-- ==========================================
-- 5. DATA INJECTION (데이터 스트림 및 JS 유닛 결합)
-- ==========================================
-- LSL 언어 내에서 실행되는 독립 로직 유닛들
@inject stream(1) {
    source: "https://api.ems-service.com/v1/latest";
    logic_unit: "units/ems_processor.js"; -- LSL 전용 데이터 가공 유닛
}

@inject stream(2) {
    source: "https://status.livesheet.org/ping";
    logic_unit: "units/sys_health.js";
}

-- ==========================================
-- 6. ENTITY DEFINITION (독립 개체 선언)
-- ==========================================
-- #notice_board는 이제 단순한 타일이 아닌 LSL의 독립 개체(Entity)입니다.
@entity #notice_board {
    bind: stream(1);
    apply: #regen_v1;
    
    -- 타일의 본질적 행동 정의
    behavior: {
        entry_anim: "flip-in";
        update_anim: "flip-out";
        hover_focus: true;
    }

    -- 4:3 그리드 시스템 기반 좌표 (솔버가 자동 계산)
    layout: {
        pos: grid(5, 5);
        span: grid(20, 15);
    }
}

@entity #status_monitor {
    bind: stream(2);
    apply: #regen_v1;
    
    -- 이 개체는 시스템 규격보다 더 빠른 독자적 박동을 가짐
    pulse_override: 10s, 20s; 
    
    layout: {
        pos: grid(30, 5);
        span: grid(10, 10);
    }
    display_type: "slide-status";
}
