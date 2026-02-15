# from PIL import Image
#
# # 设置分割规则
# row = 3
# col = 4
#
# # 打开图片
# image_path = 'img/QQ20241015-211130.png'  # 替换为你的图片路径
# image = Image.open(image_path)
#
# # 获取图片的宽度和高度
# width, height = image.size
#
# # 计算每份图片的宽度和高度
# segment_width = width // row
# segment_height = height // col
#
# # 分割图片并保存
# for i in range(row):  # 外循环控制列
#     for j in range(col):  # 内循环控制行
#         # 计算每个片段的坐标
#         left = i * segment_width
#         upper = j * segment_height
#         right = left + segment_width
#         lower = upper + segment_height
#
#         # 切片图片
#         segment = image.crop((left, upper, right, lower))
#
#         # 保存图片片段
#         segment.save(f'segment_{i}_{j}.png')  # 保存为PNG格式，可以根据需要更改格式
#
# print('图片分割完成。')



# -------------------------------------------GPT4写的---------------------------------------------------------
from PIL import Image
import os

# 分割函数
def split_image(row, col, image_path):
    # 打开图片
    img = Image.open(image_path)
    img_width, img_height = img.size

    # 计算每个小图的宽度和高度
    small_width = img_width // col
    small_height = img_height // row

    # 创建保存分割后图片的文件夹
    output_folder = "split_images"
    os.makedirs(output_folder, exist_ok=True)

    # 分割图片并保存
    for i in range(row):
        for j in range(col):
            left = j * small_width
            upper = i * small_height
            right = left + small_width
            lower = upper + small_height

            # 裁剪图片
            small_img = img.crop((left, upper, right, lower))
            small_img.save(os.path.join(output_folder, f"split_{i}_{j}.png"))

    print(f"图片已分割为 {row * col} 份，并保存在 '{output_folder}' 文件夹中。")

# 使用示例
if __name__ == "__main__":
    row = 4  # 横向分割的份数
    col = 2  # 纵向分割的份数
    image_path = 'img/accc.png'    # 替换为你的图片路径
    split_image(row,col,image_path)

