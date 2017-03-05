#!/bin/bash
# kernel build script by Tkkg1994 v0.6 (optimized from apq8084 kernel source)

export MODEL=zeroltetmo
export ARCH=arm64
export BUILD_CROSS_COMPILE=/home/geiti94/android/toolchain/gcc-linaro-6.3.1/bin/aarch64-linux-gnu-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include

PAGE_SIZE=2048
DTB_PADDING=0

if [ $MODEL = noblelte ]
then
	KERNEL_DEFCONFIG=exynos7420-noblelte_nemesis_defconfig
else if [ $MODEL = zeroflte ]
then
	KERNEL_DEFCONFIG=exynos7420-zeroflte_nemesis_defconfig
else if [ $MODEL = zerolte ]
then
	KERNEL_DEFCONFIG=exynos7420-zerolte_nemesis_defconfig
else if [ $MODEL = zerofltetmo ]
then
	KERNEL_DEFCONFIG=exynos7420-zerofltetmo_nemesis_defconfig
else if [ $MODEL = zeroltetmo ]
then
	KERNEL_DEFCONFIG=exynos7420-zeroltetmo_nemesis_defconfig
else if [ $MODEL = nobleltetmo ]
then
	KERNEL_DEFCONFIG=exynos7420-nobleltetmo_nemesis_defconfig
else if [ $MODEL = zenltetmo ]
then
	KERNEL_DEFCONFIG=exynos7420-zenltetmo_nemesis_defconfig

else [ $MODEL = zenlte ]
	KERNEL_DEFCONFIG=exynos7420-zenlte_nemesis_defconfig
fi
fi
fi
fi
fi
fi
fi

FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_DTIMAGE_TARGET()
{
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}

	case $MODEL in
	noblelte)
		DTSFILES="exynos7420-noblelte_eur_open_09"
		;;
	zeroflte)
		DTSFILES="exynos7420-zeroflte_eur_open_06"
		;;
	zerolte)
		DTSFILES="exynos7420-zerolte_eur_open_06"
		;;
	zerofltetmo)
		DTSFILES="exynos7420-zeroflte_usa_05"
		;;
	zeroltetmo)
		DTSFILES="exynos7420-zerolte_usa_06"
		;;
	nobleltetmo)
		DTSFILES="exynos7420-noblelte_usa_09"
		;;
	zenltetmo)
		DTSFILES="exynos7420-zenlte_usa_09"
		;;
	zenlte)
		DTSFILES="exynos7420-zenlte_eur_open_09"
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac

	mkdir -p $OUTDIR $DTBDIR

	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}

	rm -f ./*

	echo "Processing dts files..."

	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo "Generating dtb.img..."
	$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE

	echo "Done."
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$MODEL ""

	FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	FUNC_BUILD_DTIMAGE_TARGET
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb

	case $MODEL in
	noblelte)
		rm -f $RDIR/ramdisk/SM-N920F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-N920F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N920F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-N920F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-N920F
		./repackimg.sh
		echo SEANDROIDENFORCE >> bootn5.img
		;;
	zeroflte)
		rm -f $RDIR/ramdisk/SM-G920F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G920F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G920F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G920F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G920F
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6f.img
		;;
	zerolte)
		rm -f $RDIR/ramdisk/SM-G925F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G925F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G925F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G925F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G925F
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6e.img
		;;
	zerofltetmo)
		rm -f $RDIR/ramdisk/SM-G920T/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G920T/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G920T/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G920T/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G920T
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6ftmo.img
		;;
	zeroltetmo)
		rm -f $RDIR/ramdisk/SM-G925T/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G925T/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G925T/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G925T/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G925T
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6etmo.img
		;;
	nobleltetmo)
		rm -f $RDIR/ramdisk/SM-N920T/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-N920T/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N920T/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-N920T/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-N920T
		./repackimg.sh
		echo SEANDROIDENFORCE >> bootn5tmo.img
		;;
	zenltetmo)
		rm -f $RDIR/ramdisk/SM-G928T/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G928T/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G928T/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G928T/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G928T
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6eptmo.img
		;;
	zenlte)
		rm -f $RDIR/ramdisk/SM-G928F/split_img/boot.img-zImage
		rm -f $RDIR/ramdisk/SM-G928F/split_img/boot.img-dtb
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-G928F/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/ramdisk/SM-G928F/split_img/boot.img-dtb
		cd $RDIR/ramdisk/SM-G928F
		./repackimg.sh
		echo SEANDROIDENFORCE >> boots6ep.img
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	FUNC_BUILD_RAMDISK

    END_TIME=`date +%s`
	
    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log
