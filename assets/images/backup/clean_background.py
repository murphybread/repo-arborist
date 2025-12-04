import numpy as np
from PIL import Image
import sys
import codecs
import os
import glob

# UTF-8 출력 설정
if sys.platform == 'win32':
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

def remove_all_light_backgrounds(input_path, output_path, threshold=180):
    """밝은 배경색을 모두 투명하게 제거 (격자/체크무늬 완전 제거)"""
    try:
        # Open image and convert to RGBA
        img = Image.open(input_path).convert("RGBA")
        data = np.array(img)

        # RGB 채널 분리
        r, g, b, a = data.T

        # 모든 밝은 색상을 투명하게 (RGB 평균이 threshold 이상인 픽셀)
        # 검은 외곽선과 색상이 있는 부분만 남김
        brightness = (r.astype(float) + g.astype(float) + b.astype(float)) / 3
        light_mask = brightness > threshold

        # 투명하게 만들기
        data[..., 3][light_mask.T] = 0

        # 결과 저장
        result_img = Image.fromarray(data)
        result_img.save(output_path)
        return True

    except Exception as e:
        print(f"❌ 에러 ({os.path.basename(input_path)}): {e}")
        return False

if __name__ == "__main__":
    # 스크립트 위치 기준 etc 폴더 경로 설정
    script_dir = os.path.dirname(os.path.abspath(__file__))
    target_dir = os.path.abspath(os.path.join(script_dir, "../etc"))
    
    # 처리할 파일 목록 (투명도가 필요한 파일만 지정)
    target_files = [
        "plant_shadow.png",
        "fresh_effect_sprite_dot.png",
        "sparkling_effect_sprite_dot.png",
        "plant_neglected_overlay_sprite.png",
        "signpost_empty.png",
        "garden_border_hedge.png"
    ]
    
    print(f"📂 대상 폴더: {target_dir}")
    print("🎨 밝은 배경(흰색/회색 체크무늬) 완전 제거 시작... (Threshold: 180)\n")

    if not os.path.exists(target_dir):
        print(f"❌ 에러: 대상 폴더를 찾을 수 없습니다: {target_dir}")
        sys.exit(1)

    count = 0
    success_count = 0
    
    for filename in target_files:
        input_path = os.path.join(target_dir, filename)
        
        # 파일 존재 여부 확인
        if not os.path.exists(input_path):
            print(f"⚠️ 파일 없음: {filename}")
            continue
            
        count += 1
        print(f"[{count}/{len(target_files)}] 처리 중: {filename}...", end='', flush=True)
        
        # 임시 파일로 저장
        temp_output = input_path + ".temp.png"
        
        if remove_all_light_backgrounds(input_path, temp_output, threshold=180):
            # 성공 시 원본 덮어쓰기
            try:
                if os.path.exists(input_path):
                    os.remove(input_path)
                os.rename(temp_output, input_path)
                print(" ✅ 완료")
                success_count += 1
            except Exception as e:
                print(f" ❌ 교체 실패: {e}")
                if os.path.exists(temp_output):
                    os.remove(temp_output)
        else:
            print(" ❌ 실패")
            if os.path.exists(temp_output):
                os.remove(temp_output)

    print(f"\n✨ 총 {count}개 파일 중 {success_count}개 처리 완료!")
