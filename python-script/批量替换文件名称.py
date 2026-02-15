import os

def rename_files(directory, old_str, new_str, replace_all=False):
    """
    批量修改文件名
    :param directory: 目标目录
    :param old_str: 要替换的旧字符串
    :param new_str: 新字符串
    :param replace_all: 是否进行全名替换
    """
    for filename in os.listdir(directory):
        # 检查文件名是否包含旧字符串
        if old_str in filename:
            # 构建新的文件名
            if replace_all:
                new_filename = filename.replace(old_str, new_str)
            else:
                new_filename = filename.replace(old_str, new_str, 1)  # 只替换第一个出现的

            # 构建完整的文件路径
            old_file = os.path.join(directory, filename)
            new_file = os.path.join(directory, new_filename)

            # 重命名文件
            os.rename(old_file, new_file)
            print(f'Renamed: {old_file} -> {new_file}')

if __name__ == "__main__":
    # 目标目录路径
    dir_path = "images"
    # 要替换的旧字符串
    old_string = "split"
    # 新的字符串
    new_string = "image"
    replace_all = input("是否进行全名替换？(yes/no): ").strip().lower() == 'yes'

    # 调用重命名函数
    rename_files(dir_path, old_string, new_string, replace_all)
