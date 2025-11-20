import numpy as np
from PIL import Image
import sys
import codecs

# UTF-8 출력 설정
if sys.platform == 'win32':
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

def remove_all_light_backgrounds(input_path, output_path, threshold=200):
    """밝은 배경색을 모두 투명하게 제거 (격자 완전 제거)"""
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
        print(f"✅ 저장: {output_path}")
        return True

    except Exception as e:
        print(f"❌ 에러: {e}")
        return False

if __name__ == "__main__":
    # 원본 파일 (_old 백업본)
    files = [
        ('sprout_dot_old.png', 'sprout_dot_v3.png'),
        ('bloom_orange_dot_old.png', 'bloom_orange_dot_v3.png'),
        ('bloom_purple_dot_old.png', 'bloom_purple_dot_v3.png'),
    ]

    print("🎨 밝은 배경 완전 제거 시작...\n")

    for input_file, output_file in files:
        print(f"처리: {input_file}")
        remove_all_light_backgrounds(input_file, output_file, threshold=180)
        print()

    print("✨ 완료!")
