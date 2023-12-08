import gzip
import struct
import numpy as np
import matplotlib.pyplot as plt

def convert_mnist_images_to_verilog(input_file, output_file):
    with gzip.open(input_file, 'rb') as f:
        # Read file header information
        magic_number, num_images, rows, cols = struct.unpack('>IIII', f.read(16))
        # Read image data
        image_data = np.frombuffer(f.read(), dtype=np.uint8).reshape(num_images, rows, cols)

    with open(output_file, 'w') as verilog_file:
        # Write Verilog file header
        print ('magic number:%d, images number: %d, image size: %d*%d' % (magic_number, num_images, rows, cols))

        # Write Verilog data
        for image in image_data:
            for row in image:
                for pixel in row:
                    verilog_file.write('{:02X}\n'.format(pixel))

def convert_mnist_labels_to_verilog(input_file, output_file):
    with gzip.open(input_file, 'rb') as f:
        # 读取文件头信息
        magic_number, num_labels = struct.unpack('>II', f.read(8))
        # 读取标签数据
        label_data = np.frombuffer(f.read(), dtype=np.uint8)

    with open(output_file, 'w') as verilog_file:
        # Write Verilog file header
        print ('magic number:%d, labels number: %d' % (magic_number, num_labels))

        # 写入Verilog数据，每个标签进行一次换行
        for label in label_data:
            verilog_file.write('{:02X}\n'.format(label))


def show_mnist_images(input_file, num_images=3):
    with gzip.open(input_file, 'rb') as f:
        # 读取文件头信息
        magic_number, num_images_total, rows, cols = struct.unpack('>IIII', f.read(16))
        # 读取图像数据
        image_data = np.frombuffer(f.read(), dtype=np.uint8).reshape(num_images_total, rows, cols)

    # 显示前num_images张图像
    for i in range(min(num_images, num_images_total)):
        plt.imshow(image_data[i], cmap='gray')
        plt.title('MNIST Image {}'.format(i+1))
        plt.show()

# Specify input and output files
ref_images_input_file = 'train-images-idx3-ubyte.gz'
ref_images_output_file = 'ref-images.hex'
ref_labels_input_file = 'train-labels-idx1-ubyte.gz'
ref_labels_output_file = 'ref-labels.hex'

test_images_input_file = 't10k-images-idx3-ubyte.gz'
test_images_output_file = 'test-images.hex'
test_labels_input_file = 't10k-labels-idx1-ubyte.gz'
test_labels_output_file = 'test-labels.hex'

# Convert MNIST image data to Verilog format
convert_mnist_images_to_verilog(ref_images_input_file, ref_images_output_file)
convert_mnist_labels_to_verilog(ref_labels_input_file, ref_labels_output_file)
convert_mnist_images_to_verilog(test_images_input_file, test_images_output_file)
convert_mnist_labels_to_verilog(test_labels_input_file, test_labels_output_file)
# 展示3张训练图片
show_mnist_images(ref_images_input_file, num_images=3)