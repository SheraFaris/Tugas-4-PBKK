import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateLikeDto } from './dto/create-like.dto';
import { UpdateLikeDto } from './dto/update-like.dto';

@Injectable()
export class LikesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createLikeDto: CreateLikeDto) {
    return this.prisma.like.create({
      data: createLikeDto,
    });
  }

  async findAll() {
    return this.prisma.like.findMany();
  }

  async findOne(id: number) {
    return this.prisma.like.findUnique({
      where: { id },
    });
  }

  async update(id: number, updateLikeDto: UpdateLikeDto) {
    return this.prisma.like.update({
      where: { id },
      data: updateLikeDto,
    });
  }

  async remove(id: number) {
    return this.prisma.like.delete({
      where: { id },
    });
  }
}
