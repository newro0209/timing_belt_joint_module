// =====================================================
// 공통 파라미터 — 풀리 내장형 벨트 감속 관절 모듈
// 좌표 규약:
//  - 베이스 플레이트 윗면 = z 0 (베이스는 z -base_t .. 0)
//  - 출력축(스트리퍼 볼트) 중심 = (0, 0)
//  - 모터축 중심 = (-axis_dist, 0)
//  - 암은 +x 방향(모터 반대쪽)으로 뻗는다
// =====================================================

axis_dist = 99.2;     // 축간거리 C
base_t    = 8;        // 베이스 플레이트 두께

// ---- 베이스 플레이트 외형 ----
base_x_min = -140;  base_x_max = 38;
base_y_half = 40;
base_corner_r = 8;

// ---- 출력축 적층 (쇼울더 L25 기준, z는 베이스 윗면 기준) ----
standoff_h   = 3;                       // 스탠드오프 스페이서 z 0..3
brg_od = 22; brg_id = 8; brg_w = 7;     // 608ZZ
lower_brg_z0 = standoff_h;              // 하부 베어링 z 3..10
spacer_h     = 8;                       // 내륜 스페이서 z 10..18
upper_brg_z0 = standoff_h + brg_w + spacer_h;  // 상부 베어링 z 18..25
shoulder_top = upper_brg_z0 + brg_w;    // z 25
shim_t       = 0.2;                     // 심 와셔 z 25..25.2
top_washer_t = 1.2;                     // 상부 와셔 z 25.2..26.4
bolt_head_d  = 13;  bolt_head_h = 5.5;  // 스트리퍼 볼트 머리
spacer_od    = 12;                      // 스페이서류 외경

// ---- 암 허브 / 클램프 ----
hub_od        = 32;
hub_z0        = 3;   hub_z1 = 26;       // 허브 본체 z 범위
hub_flange_od = 58;                     // 클램프 볼트 받이 플랜지
hub_flange_z0 = 10.8; hub_flange_z1 = 13.0;
arm_len       = 85;  arm_w = 26;        // 암: z 20..26, +x 방향
arm_z0        = 20;  arm_z1 = 26;
clamp_pcd     = 50;                     // M3 클램프 볼트 PCD
clamp_bolt_angles = [90, 210, 330];     // +x(암) 방향 회피
clamp_ring_od = 56;  clamp_ring_id = 14;
clamp_ring_z0 = 0.8; clamp_ring_z1 = 3.8;

// ---- 출력 풀리 GT2 60T (10mm bore, 무가공) ----
p60_pd   = 60 * 2 / PI;                 // 약 38.2
p60_od   = 40.4;                        // 이빨 외경 근사
p60_flange_d = 46;
p60_bore = 13;                          // 시각화용(센터링 보스 영역 포함)
p60_z0   = 3.8;  p60_z1 = 10.8;         // 본체 z 범위

// ---- 벨트 GT2-280, 6mm 폭 ----
belt_w  = 6;
belt_t  = 1.5;
belt_z0 = 4.3;                          // z 4.3..10.3
p20_pd  = 20 * 2 / PI;                  // 약 12.7

// ---- NEMA 17 + 20T 풀리 ----
nema_side   = 42.3;
nema_len    = 40;                       // 몸체 z -48..-8 (베이스 아래 매달림)
nema_hole_pitch = 31;                   // M3 4개, 정사각
nema_boss_d = 22;   nema_boss_h = 2;
nema_shaft_d = 5;
nema_shaft_top = 16;                    // 베이스 윗면 기준 축 끝 z
p20_od   = 12.2;                        // 이빨 외경 근사
p20_flange_d = 18;
p20_z0   = 2.8;  p20_z1 = 12.8;         // 플랜지 포함 본체

// ---- 모터 슬롯 / 잭 스크류 ----
slot_w = 3.4;  slot_l = 12;             // 장축은 x 방향(두 풀리 중심선과 평행)
boss_slot_w = 22.5; boss_slot_l = 34.5;
jack_block_x = -axis_dist - 32;         // 모터 뒤쪽 블록 중심 x
jack_block = [10, 14, 14];              // 블록 크기 (베이스 윗면 위)

// ---- 색상 ----
c_print  = [0.30, 0.55, 0.85];          // 프린팅 부품 (파랑 계열)
c_print2 = [0.40, 0.70, 0.95];
c_steel  = [0.75, 0.76, 0.78];
c_alu    = [0.85, 0.86, 0.88];
c_brass  = [0.80, 0.65, 0.25];
c_belt   = [0.15, 0.15, 0.15];
c_motor  = [0.25, 0.25, 0.28];

$fa = 4; $fs = 0.4;
