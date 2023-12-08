import random

# 生成 512 个随机 32 位十六进制数据
data = [random.randint(0, 0xFFFFFFFF) for _ in range(512)]

# 将数据写入文件
with open('input_data.txt', 'w') as file:
    for i, value in enumerate(data):
        hex_value = format(value, '08X')  # 将整数转换为十六进制字符串
        file.write(hex_value + ' ')
        
        if (i + 1) % 128 == 0:  # 每128个数据后添加一个换行
            file.write('\n')
